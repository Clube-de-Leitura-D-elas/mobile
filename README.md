# Clube de Leitura D'Elas — App Mobile

[![Flutter CI & Coverage](https://github.com/Clube-de-Leitura-D-elas/mobile/actions/workflows/ci.yml/badge.svg)](https://github.com/Clube-de-Leitura-D-elas/mobile/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/Clube-de-Leitura-D-elas/mobile/branch/develop/graph/badge.svg)](https://codecov.io/gh/Clube-de-Leitura-D-elas/mobile)

Plataforma mobile/web responsiva para gestão e organização do Clube de Leitura D'Elas.

---

## 🛠️ Tecnologias

- **Flutter / Dart** (SDK 3.11+)
- **Clean Architecture** com organização Feature-First
- **GetIt** (Injeção de dependências)
- **Dio** (HTTP Client)
- **Supabase Flutter** (Banco de dados e autenticação)
- **Mocktail** (Testes unitários e Mocks)
- **l10n / intl** (Internacionalização pt_BR)

---

## 🌐 Internacionalização e Geração de Strings (`l10n`)

O projeto utiliza o pacote oficial do Flutter para localização e internacionalização (`flutter_localizations` / `intl`).

### 1. Estrutura dos Arquivos ARB

As strings traduzidas ficam localizadas em `lib/l10n/`:
- `lib/l10n/app_pt.arb` (Arquivo template principal)
- `lib/l10n/app_pt_BR.arb` (Especificidades de pt_BR)

Para adicionar uma nova string, insira a chave no arquivo ARB desejado:

```json
{
  "welcomeMessage": "Bem-vinda ao Clube de Leitura D'Elas!",
  "@welcomeMessage": {
    "description": "Mensagem de boas-vindas exibida na Home"
  }
}
```

---

### 2. Gerando as Strings de Localização

Sempre que adicionar ou modificar uma string em um arquivo `.arb`, execute o comando:

```bash
flutter gen-l10n
```

> **Nota:** Se a opção `generate: true` estiver habilitada no `pubspec.yaml` (já configurada), o Flutter gerará as traduções automaticamente ao rodar `flutter pub get`, `flutter test` ou `flutter run`.

---

### 3. Como Utilizar no Código

As strings geradas ficam disponíveis via extensão de contexto [`BuildContext`](file:///Users/natandias/workspace/ages/mobile/lib/core/extensions/build_context_l10n.dart):

```dart
import 'package:mobile/core/extensions/build_context_l10n.dart';

Text(context.l10n.welcomeMessage)
```

---

## 🧪 Testes e Cobertura de Código (`lcov`)

### 1. Executando os Testes Unitários

Para rodar todos os testes unitários do projeto:

```bash
flutter test
```

Para rodar um arquivo de teste específico:

```bash
flutter test test/core/http/dio_adapter_test.dart
```

---

### 2. Gerando a Cobertura de Código (`lcov.info`)

Para executar os testes e gerar o relatório de cobertura `lcov`:

```bash
flutter test --coverage
```

Isso criará o arquivo `coverage/lcov.info` na raiz do projeto (este diretório está configurado no `.gitignore`).

---

### 3. Visualizando o Relatório HTML de Cobertura (`lcov` / `genhtml`)

Para converter o arquivo `lcov.info` em um relatório visual HTML interativo no seu navegador:

#### **Pré-requisito (Instalar `lcov`):**

- **macOS (Homebrew):**

  ```bash
  brew install lcov
  ```

- **Linux (Ubuntu/Debian):**

  ```bash
  sudo apt-get install lcov
  ```

#### **Gerar e abrir o relatório HTML:**

```bash
# 1. Gerar os arquivos HTML a partir do lcov.info
genhtml coverage/lcov.info -o coverage/html

# 2. Abrir o relatório no navegador
# macOS:
open coverage/html/index.html

# Linux:
xdg-open coverage/html/index.html
```

---

### 4. Filtrando Arquivos Gerados da Cobertura *(Opcional)*

Se desejar remover arquivos de internacionalização gerados (`lib/l10n/`) ou arquivos auto-gerados (`*.g.dart`) do relatório de cobertura:

```bash
lcov --remove coverage/lcov.info 'lib/l10n/*' '*.g.dart' -o coverage/lcov.info
genhtml coverage/lcov.info -o coverage/html
```

---

## 📚 Documentação do Projeto

Para acessar a documentação completa no Wiki, [clique aqui](https://tools.ages.pucrs.br/clube-de-leitura-d-elas/wiki/-/wikis/home).

---

## 🎓 Semestre

AGES 2026/2 — Turma 3JK5JK
