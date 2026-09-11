# Ícones do app (pipeline SVG → SI)

Os ícones do app são exportados do Figma como `.svg`, convertidos para o
formato binário `.si` do pacote [jovial_svg](https://pub.dev/packages/jovial_svg)
e consumidos em runtime pelo widget `AppIcon` (`lib/design_system/widgets/app_icon.dart`).

O `.si` evita reparsear a árvore SVG toda vez que o ícone é desenhado —
ele já vem pré-compilado numa representação binária que o `jovial_svg`
carrega direto.

## Por que só um arquivo por ícone (sem variante de cor)

Os ícones do "Quick Access" no Figma aparecem em duas cores (cinza
padrão / rosa quando ativo). Em vez de exportar duas `.svg`/`.si` por
ícone, exportamos **um único arquivo neutro** e aplicamos a cor em
runtime com `ColorFilter.mode(cor, BlendMode.srcIn)` dentro do
`AppIcon` — a cor vem dos tokens do tema (`colors.textMuted` para
inativo, `colors.actionPrimary` para ativo), igual o resto dos widgets
do design system já faz. Isso metade a quantidade de assets e evita
duplicar arquivo toda vez que a paleta mudar.

## Passo a passo

### 1. Exportar do Figma

No Figma, selecione a camada do ícone → botão direito → **Copy/Export as SVG**
(ou o painel de Export com formato SVG). Salve em `assets/icons/svg/`
com um nome descritivo em snake_case (ex: `nav_home.svg`).

> Ícones já presentes nesta entrega (`nav_home`, `nav_search`, `nav_add`,
> `nav_calendar`, `nav_profile`) são **placeholders desenhados à mão** —
> ninguém exportou o vetor real do Figma ainda. Antes de ir para produção,
> reexporte cada um com o nome de arquivo idêntico para substituir sem
> precisar tocar em mais nada do pipeline.

### 2. Adicionar a dependência do jovial_svg

No `pubspec.yaml` do projeto:

```yaml
dependencies:
  jovial_svg: ^1.1.30 # confirmado pelo log de `dart pub global activate jovial_svg`

dev_dependencies:
  # jovial_svg:svg_to_si é a CLI de conversão, já vem com o próprio pacote —
  # não precisa de uma dependência separada, só rodar `dart run jovial_svg:svg_to_si`
  # depois de declarar jovial_svg acima e rodar `dart pub get`.
```

Rode `flutter pub add jovial_svg` na raiz do projeto em vez de editar a
mão, se preferir — ele já adiciona a linha certa e roda o `pub get`.

### 3. Converter para `.si`

```bash
dart run tool/convert_icons.dart
```

Isso roda `dart run jovial_svg:svg_to_si` uma vez, passando todos os
`.svg` de `assets/icons/svg/` como entrada, e escreve o `.si`
correspondente de cada um em `assets/icons/si/`.

Para converter um ícone novo manualmente (sem o script):

```bash
dart run jovial_svg:svg_to_si -o assets/icons/si assets/icons/svg/novo_icone.svg
```

Flags confirmadas via `dart run jovial_svg:svg_to_si --help`:

```
dart run jovial_svg:svg_to_si [options] <input files>
    -o, --out              output directory
    -h, --[no-]help        show help message
    -b, --[no-]big         Use 64 bit double-precision floats, instead of 32
    -q, --[no-]quiet       Quiet: Suppress warnings
    -e, --export           Export: Export the given ID (múltiplos valores)
    -x, --exportx          Export: Export the IDs matched by regex (múltiplos valores)
```

`-e`/`-x` só interessam se um `.svg` tiver múltiplos elementos com ID e
você quiser exportar só um deles como `.si` — não é o nosso caso (cada
`.svg` já é um ícone único).

### 4. Declarar no `pubspec.yaml`

```yaml
flutter:
  assets:
    - assets/icons/si/
```

Só a pasta dos `.si` precisa estar aqui — os `.svg` são só o arquivo
fonte, não são usados em runtime.

### 5. Registrar o ícone no `AppIcon`

Adicione uma entrada no enum `AppIconName`
(`lib/design_system/widgets/app_icon.dart`):

```dart
enum AppIconName {
  home('nav_home'),
  search('nav_search'),
  add('nav_add'),
  calendar('nav_calendar'),
  profile('nav_profile'),
  novoIcone('novo_icone'), // <- nome do arquivo sem extensão
  ;
  // ...
}
```

### 6. Usar no app

```dart
AppIcon(AppIconName.home, color: colors.actionPrimary) // ativo
AppIcon(AppIconName.home) // inativo — usa colors.textMuted por padrão
```

## Runbook rápido (novo ícone a partir de agora)

1. Exportar `.svg` do Figma → `assets/icons/svg/<nome>.svg`
2. `dart run tool/convert_icons.dart`
3. Conferir que `assets/icons/si/<nome>.si` foi gerado
4. Adicionar `<nome>` ao enum `AppIconName`
5. `flutter test` para rodar `test/design_system/widgets/app_icon_test.dart`
6. Commitar `.svg` + `.si` juntos

## Testes

`test/design_system/widgets/app_icon_test.dart` cobre o `AppIcon` sem
depender de arquivos `.si` reais no disco: o loader é injetável
(`@visibleForTesting loader`), então os testes usam um SVG mínimo
parseado em memória via `ScalableImage.fromSvgString`. Isso valida o
contrato do widget (tint aplicado, tamanho respeitado, comportamento
quando o asset falha ao carregar) sem exigir que a conversão `.si` já
tenha rodado antes do `flutter test`.

O que os testes **não** cobrem (e não dá pra automatizar de forma
confiável): se o comando `dart run jovial_svg:svg_to_si` de fato foi
executado e os `.si` reais estão presentes/commitados. Isso é checado
manualmente no code review do PR (ou dá pra adicionar um step de CI que
roda `tool/convert_icons.dart` e falha o build se `git status` mostrar
`.si` desatualizado em relação ao `.svg` correspondente).
