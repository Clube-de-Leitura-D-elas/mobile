import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('pt'),
    Locale('pt', 'BR'),
  ];

  /// Nome principal do aplicativo
  ///
  /// In pt, this message translates to:
  /// **'Clube de Leitura D\'elas'**
  String get appTitle;

  /// Mensagem de boas-vindas na tela inicial
  ///
  /// In pt, this message translates to:
  /// **'Bem-vinda!'**
  String get welcomeMessage;

  /// Texto padrão para botão de confirmação simples
  ///
  /// In pt, this message translates to:
  /// **'OK'**
  String get ok;

  /// Texto padrão para botão de cancelamento
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// Texto padrão para ação de salvar
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get save;

  /// Texto padrão para ação de exclusão
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get delete;

  /// Texto padrão para ação de edição
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get edit;

  /// Texto padrão para confirmação de ação
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// Texto padrão para ação de retornar
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get back;

  /// Texto padrão para ação de fechar modal ou tela
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get close;

  /// Texto para tentar executar uma ação novamente
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get retry;

  /// Texto padrão para campo ou botão de busca
  ///
  /// In pt, this message translates to:
  /// **'Buscar'**
  String get search;

  /// Texto para botão de prosseguir em fluxos
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get continueAction;

  /// Mensagem genérica para erros desconhecidos
  ///
  /// In pt, this message translates to:
  /// **'Ocorreu um erro inesperado. Tente novamente.'**
  String get errorGeneric;

  /// Mensagem de erro de conexão com a internet
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão com a internet. Verifique sua rede e tente novamente.'**
  String get errorNetwork;

  /// Mensagem para timeout de rede ou servidor
  ///
  /// In pt, this message translates to:
  /// **'O tempo de resposta da requisição esgotou. Tente novamente.'**
  String get errorTimeout;

  /// Mensagem de erro para acesso não autorizado (HTTP 401)
  ///
  /// In pt, this message translates to:
  /// **'Sessão expirada ou não autorizada. Por favor, faça login novamente.'**
  String get errorUnauthorized;

  /// Mensagem de erro para ação proibida (HTTP 403)
  ///
  /// In pt, this message translates to:
  /// **'Você não tem permissão para realizar esta ação.'**
  String get errorForbidden;

  /// Mensagem de erro para recurso não encontrado (HTTP 404)
  ///
  /// In pt, this message translates to:
  /// **'O recurso solicitado não foi encontrado.'**
  String get errorNotFound;

  /// Mensagem de erro para requisição malformada (HTTP 400)
  ///
  /// In pt, this message translates to:
  /// **'Requisição inválida. Verifique os dados e tente novamente.'**
  String get errorBadRequest;

  /// Mensagem de erro para erro interno no servidor (HTTP 500)
  ///
  /// In pt, this message translates to:
  /// **'Ocorreu uma falha nos nossos servidores. Tente novamente mais tarde.'**
  String get errorInternalServer;

  /// Título principal da tela de login
  ///
  /// In pt, this message translates to:
  /// **'Faça o seu login'**
  String get loginTitle;

  /// Rótulo para campo de e-mail
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get emailLabel;

  /// Texto de dica para campo de e-mail
  ///
  /// In pt, this message translates to:
  /// **'seu@email.com'**
  String get emailHint;

  /// Rótulo para campo de senha
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get passwordLabel;

  /// Link de esqueci minha senha
  ///
  /// In pt, this message translates to:
  /// **'Esqueci minha senha'**
  String get forgotPasswordLink;

  /// Botão de login social com Google
  ///
  /// In pt, this message translates to:
  /// **'Entrar com Google'**
  String get signInWithGoogle;

  /// Link para criação de nova conta
  ///
  /// In pt, this message translates to:
  /// **'Primeiro acesso? Crie sua conta aqui'**
  String get createAccountLink;

  /// Mensagem de validação de e-mail obrigatório
  ///
  /// In pt, this message translates to:
  /// **'Por favor, informe seu e-mail'**
  String get emailRequiredError;

  /// Mensagem de validação de formato de e-mail inválido
  ///
  /// In pt, this message translates to:
  /// **'Informe um e-mail válido'**
  String get emailInvalidError;

  /// Mensagem de validação de senha obrigatória
  ///
  /// In pt, this message translates to:
  /// **'Por favor, informe sua senha'**
  String get passwordRequiredError;

  /// Mensagem de feedback de sucesso ao confirmar presença
  ///
  /// In pt, this message translates to:
  /// **'Presença confirmada!'**
  String get toastSuccessAttendance;

  /// Mensagem de feedback de erro ao salvar
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar. Tente de novo.'**
  String get toastErrorSave;

  /// Mensagem de alerta quando o encontro não possui local
  ///
  /// In pt, this message translates to:
  /// **'O encontro ainda está sem local.'**
  String get toastWarningLocation;

  /// Mensagem informativa após avisar as participantes
  ///
  /// In pt, this message translates to:
  /// **'As participantes foram avisadas.'**
  String get toastInfoNotified;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
