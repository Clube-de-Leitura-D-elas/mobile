// Converte todos os .svg de assets/icons/svg/ para .si em
// assets/icons/si/, usando a CLI do pacote jovial_svg.
//
// Uso:
//   dart run tool/convert_icons.dart
//   (rode a partir da raiz do projeto — onde fica o pubspec.yaml)
//
// Pré-requisito: jovial_svg precisa estar em dependencies no
// pubspec.yaml (`flutter pub add jovial_svg`).
//
// Flags confirmadas via `dart run jovial_svg:svg_to_si --help`:
//   dart run jovial_svg:svg_to_si [options] <input files>
//     -o, --out   output directory
// (multiplos arquivos de entrada num só comando são suportados, por
// isso convertemos tudo numa chamada em vez de uma por ícone.)
import 'dart:io';

const _svgDir = 'assets/icons/svg';
const _siDir = 'assets/icons/si';

Future<void> main() async {
  final svgDirectory = Directory(_svgDir);
  if (!svgDirectory.existsSync()) {
    stderr.writeln('Pasta $_svgDir não existe.');
    exitCode = 1;
    return;
  }

  final svgFiles = svgDirectory
      .listSync()
      .whereType<File>()
      .where((file) => file.path.toLowerCase().endsWith('.svg'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  if (svgFiles.isEmpty) {
    stdout.writeln('Nenhum .svg encontrado em $_svgDir.');
    return;
  }

  Directory(_siDir).createSync(recursive: true);

  final inputPaths = svgFiles.map((f) => f.path).toList();
  final args = ['-o', _siDir, ...inputPaths];

  stdout.writeln('Convertendo ${svgFiles.length} ícone(s) para .si...');
  stdout.writeln('→ dart run jovial_svg:svg_to_si ${args.join(' ')}\n');

  final result = await Process.run('dart', ['run', 'jovial_svg:svg_to_si', ...args]);

  stdout.write(result.stdout);
  if (result.exitCode != 0) {
    stderr.write(result.stderr);
    stderr.writeln('\nConversão falhou (exit code ${result.exitCode}).');
    exitCode = 1;
    return;
  }

  stdout.writeln('Todos os ícones convertidos com sucesso em $_siDir/.');
}
