# AGENTS.md — Mobile

Instruções para agentes de IA (Claude Code, Copilot, Cursor) e para o revisor automático
(CodeRabbit). É a fonte única das regras do repositório: o `CLAUDE.md` e o
`.github/copilot-instructions.md` só apontam para cá. O `README.md` continua sendo o guia de setup
para pessoas.

Quem revisa um PR usa as seções **Regras** e **Checklist de review** como critério. Uma regra
quebrada é achado de review, mesmo que o código "funcione". As regras valem para o código novo ou
alterado no PR; quem revisa não exige refactor de código que o PR não tocou.

## O que é este repositório

App Flutter (Android e iOS) do Clube de Leitura D'Elas, usado pelas leitoras e coordenadoras. O
backend é o Supabase do repositório [`backend`](https://github.com/Clube-de-Leitura-D-elas/backend).

```
lib/
├── core/            # infraestrutura: supabase, http, rotas, service locator, extensões
├── design_system/   # tokens (cor, espaçamento, tipografia) e widgets App*
├── features/<nome>/
│   ├── data/          # datasources, models, implementação dos repositories
│   ├── domain/        # entities e contratos dos repositories
│   └── presentation/  # cubit, pages, widgets, routes
├── l10n/            # strings (app_pt.arb, app_pt_BR.arb)
└── dependencies.dart  # registro das dependências (GetIt via ServiceLocator)
test/                # espelha lib/
```

## Comandos

```bash
cp .env.example .env  # uma vez; o .env é asset do app e o build falha sem ele
flutter pub get
flutter gen-l10n      # depois de mexer em .arb
flutter analyze       # o CI falha com qualquer issue
flutter test          # o CI roda com --coverage e manda para o Codecov
```

## Regras

### Arquitetura

- Clean Architecture por feature. `presentation` depende de `domain`; só `data` conhece
  Supabase, models e JSON. Página e cubit não chamam o Supabase direto. A exceção é o
  `SessionCubit` (`features/auth`), que observa a sessão do Supabase Auth.
- Chamadas ao backend passam pelo `SupabaseService` (`lib/core/supabase/`), via
  `invokeFunction`, na camada `data` da feature (datasource ou implementação do
  repository). O retorno é um `Result` (`core/tools`):
  trate o `Failure`, não o ignore.
- O nome da function e os campos do body seguem o contrato da Edge Function do backend
  (`supabase/functions/<nome>/index.ts` no repositório backend). Se o backend renomear ou mudar
  um campo, troque em todos os lugares do app e nos testes.
- Dependência nova é registrada em `lib/dependencies.dart`.
- Estado de tela com `Cubit` em `presentation/cubit/`, com estados de carregamento, sucesso e erro
  explícitos.

### Design system

- Cor, espaçamento e tipografia sempre pelos tokens: `context.colors`, `context.spacing`,
  `context.typography`. Nada de `Color(0x...)`, `Colors.*` ou número mágico de espaçamento em
  tela de feature.
- Use os widgets de `lib/design_system/widgets/` (`AppButton`, `AppCard`, `AppTextField`,
  `AppDialog`, `AppToast`, `Gap*` etc.) antes de montar um equivalente na feature. Modal novo usa
  `AppDialog`.
- Widget novo do design system é exportado em `design_system.dart` e tem teste em
  `test/design_system/`.
- Ícone novo entra como SVG em `assets/icons/svg/` e é convertido para `.si` com o
  `jovial_svg` (comando em `icons.md`).

### Textos

- Todo texto visível vem do l10n: chave nova em `lib/l10n/app_pt.arb` com a entrada `@chave` e
  `description`, acesso por `context.l10n.<chave>`. String literal em widget é achado de review.
- **Armadilha:** `app_pt_BR.arb` sobrescreve boa parte das chaves do `app_pt.arb`, e os aparelhos
  em pt_BR (a maioria das usuárias) leem dele. Para mudar um texto que já existe, mude nos dois
  arquivos; mudar só o `app_pt.arb` não muda nada na tela. O `app_pt_BR.arb` não leva as entradas
  `@chave`.
- Depois de mexer em `.arb`, rode `flutter gen-l10n` e commite os arquivos gerados.

### Acessibilidade

- Acessibilidade é requisito, não extra. Siga a tabela de `Semantics` do README: botões com
  `button: true` e `label`, selecionáveis com `selected`, expansíveis com `expanded`, validações
  com `checked`, avisos dinâmicos com `liveRegion`, imagens informativas com `image` e `label`,
  decoração em `ExcludeSemantics`.
- Alvo de toque de no mínimo 48×48.
- Os rótulos semânticos também são usados pela automação (Marionette MCP); mantenha-os estáveis
  e descritivos.

### Testes

- O teste espelha o caminho de `lib/` em `test/` e usa `mocktail`.
- Mudança de comportamento vem com teste novo ou atualizado: model (JSON), datasource (nome da
  function e body), repository (`Success`/`Failure`), cubit (sequência de estados) e widget (o que
  aparece e as interações).
- O teste precisa falhar se o comportamento quebrar; asserção que só confere que "não lançou" não
  conta.

### Estilo

- `analysis_options.yaml` é a régua (aspas simples, chaves em todo `if`, tipos de retorno
  declarados). `flutter analyze` sem nenhum aviso.
- Imports de outras pastas de `lib/` usam `package:mobile/...`; import relativo só entre arquivos
  vizinhos da mesma pasta.
- Comentários em pt-BR e só quando essenciais: o porquê que o código não mostra ou a armadilha que
  quebra em silêncio.

## Checklist de review

1. O PR faz o que a descrição promete, e o código novo é usado?
2. A camada certa faz cada coisa (nada de Supabase em página ou cubit)? O `Failure` é tratado?
3. O contrato com a Edge Function bate com o backend?
4. Algum texto fora do l10n, cor ou espaçamento fora dos tokens, widget duplicando um do design
   system?
5. `Semantics` e alvo de toque estão certos nos elementos novos?
6. Os testes cobrem a mudança e falhariam se ela quebrasse?
7. Tela nova ou alterada tem o print no PR (Código × Figma)?

## Branches, commits e PR

- Branch base `develop`; `main` fica para as versões apresentadas aos stakeholders.
- Branch: `<type>/CLU-<numero>-<descricao-curta>` (o Linear vincula branch, PR e issue).
- Commits em [Conventional Commits](https://www.conventionalcommits.org/), em inglês e no
  imperativo. Types: `feat`, `fix`, `refactor`, `test`, `chore`, `docs`, `ci`.
- PR com o template do repositório preenchido, incluindo o **Resultado Visual**. O CI
  (`flutter analyze` + `flutter test --coverage`) precisa estar verde.

## Ambiente local (opcional, máquina com pouca RAM)

Dicas para rodar no Android numa máquina com cerca de 16 GB de RAM sem travar o sistema. Não são
regras de código nem de review.

**Uma vez só:**

1. Limite o Gradle em `~/.gradle/gradle.properties` (vale mais que o arquivo do projeto, que
   permite até 8 GB de heap):

   ```properties
   org.gradle.jvmargs=-Xmx2g -XX:MaxMetaspaceSize=512m -XX:+HeapDumpOnOutOfMemoryError
   org.gradle.workers.max=4
   kotlin.daemon.jvmargs=-Xmx1g
   ```

2. Instale o earlyoom, para o Linux matar o maior processo em vez de travar:

   ```bash
   sudo apt install earlyoom && sudo systemctl enable --now earlyoom
   ```

**A cada sessão:**

1. Feche o que não precisa: o Docker Desktop (a VM dele reserva vários GB), a não ser que o
   backend local esteja em uso, e abas extras do navegador.
2. Suba o emulador com 2 GB e 2 núcleos (`Pixel_5_API_34` é a imagem mais leve, sem Play Store):

   ```bash
   ~/Android/Sdk/emulator/emulator -avd Pixel_5_API_34 -memory 2048 -cores 2 -gpu host -no-boot-anim -no-audio &
   ```

3. Rode o app com teto de 6 GB no build (ele é morto em vez de travar o PC):

   ```bash
   systemd-run --user --scope -p MemoryMax=6G flutter run -d emulator-5554
   ```

4. Com o app aberto, libere os daemons do Gradle (~2,3 GB); o hot reload continua funcionando:

   ```bash
   (cd android && ./gradlew --stop)
   ```

5. Use `r` (hot reload) e `R` (hot restart) no terminal do `flutter run`. Só rode `flutter run`
   de novo depois de mudar `pubspec.yaml`, `.env` ou arquivos nativos do Android.

Confira a memória com `free -h`; se o `available` cair abaixo de ~1,5 GB, feche algo. Um celular
físico com depuração USB dispensa o emulador (~3 GB a menos).

**Para agentes:** com o `flutter run` em background (sem stdin), dispare o hot reload com
`kill -USR1 <pid do flutter_tools>` e o hot restart com `kill -USR2 <pid>`. Não pare o Docker
Desktop sem perguntar: ele pode estar rodando o Supabase local.
