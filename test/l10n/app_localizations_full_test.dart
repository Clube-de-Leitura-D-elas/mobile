import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  group('AppLocalizations Full Coverage', () {
    test('loads pt and pt_BR localizations and validates all getters', () async {
      for (final locale in [const Locale('pt'), const Locale('pt', 'BR')]) {
        final l10n = await AppLocalizations.delegate.load(locale);

        expect(l10n.appTitle, isNotEmpty);
        expect(l10n.welcomeMessage, isNotEmpty);
        expect(l10n.ok, equals('OK'));
        expect(l10n.cancel, equals('Cancelar'));
        expect(l10n.save, equals('Salvar'));
        expect(l10n.delete, equals('Excluir'));
        expect(l10n.edit, equals('Editar'));
        expect(l10n.confirm, equals('Confirmar'));
        expect(l10n.back, equals('Voltar'));
        expect(l10n.close, equals('Fechar'));
        expect(l10n.retry, isNotEmpty);
        expect(l10n.search, equals('Buscar'));
        expect(l10n.continueAction, equals('Continuar'));
        expect(l10n.errorGeneric, isNotEmpty);
        expect(l10n.errorNetwork, isNotEmpty);
        expect(l10n.errorTimeout, isNotEmpty);
        expect(l10n.errorUnauthorized, isNotEmpty);
        expect(l10n.errorForbidden, isNotEmpty);
        expect(l10n.errorNotFound, isNotEmpty);
        expect(l10n.errorBadRequest, isNotEmpty);
        expect(l10n.errorInternalServer, isNotEmpty);
        expect(l10n.loginTitle, isNotEmpty);
        expect(l10n.emailLabel, isNotEmpty);
        expect(l10n.emailHint, isNotEmpty);
        expect(l10n.passwordLabel, isNotEmpty);
        expect(l10n.forgotPasswordLink, isNotEmpty);
        expect(l10n.signInWithGoogle, isNotEmpty);
        expect(l10n.createAccountLink, isNotEmpty);
        expect(l10n.emailRequiredError, isNotEmpty);
        expect(l10n.emailInvalidError, isNotEmpty);
        expect(l10n.passwordRequiredError, isNotEmpty);
      }
    });

    test('delegate props and isSupported test', () {
      final delegate = AppLocalizations.delegate;

      expect(delegate.isSupported(const Locale('pt')), isTrue);
      expect(delegate.isSupported(const Locale('pt', 'BR')), isTrue);
      expect(delegate.isSupported(const Locale('en')), isFalse);
      expect(delegate.shouldReload(delegate), isFalse);
    });
  });
}
