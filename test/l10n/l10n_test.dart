import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLocalizations pt_BR', () {
    test('loads Portuguese (pt_BR) localizations correctly', () async {
      final localizations = await AppLocalizations.delegate.load(
        const Locale('pt', 'BR'),
      );

      expect(localizations.appTitle, equals("Clube de Leitura D'elas"));
      expect(localizations.welcomeMessage, equals('Bem-vinda!'));
      expect(localizations.ok, equals('OK'));
      expect(localizations.cancel, equals('Cancelar'));
      expect(localizations.save, equals('Salvar'));
      expect(localizations.delete, equals('Excluir'));
      expect(localizations.errorGeneric, contains('Ocorreu um erro inesperado'));
      expect(localizations.errorNetwork, contains('Sem conexão com a internet'));
    });
  });
}
