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

  /// Texto para botão de prosseguir em fluxos
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get continueAction;

  /// Texto padrão para confirmação de ação
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// Valor padrão quando uma informação não foi preenchida
  ///
  /// In pt, this message translates to:
  /// **'Não informado'**
  String get notProvided;

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

  /// Mensagem de aviso para confirmar e-mail antes de fazer login
  ///
  /// In pt, this message translates to:
  /// **'Por favor, confirme seu e-mail antes de logar.'**
  String get confirmEmailBeforeLoginError;

  /// Título da tela de cadastro de usuário
  ///
  /// In pt, this message translates to:
  /// **'Criar Conta'**
  String get registerTitle;

  /// Rótulo para campo de confirmação de senha
  ///
  /// In pt, this message translates to:
  /// **'Confirmar Senha'**
  String get confirmPasswordLabel;

  /// Requisito de validação de tamanho mínimo de senha
  ///
  /// In pt, this message translates to:
  /// **'Pelo menos 8 caracteres'**
  String get passwordMinLengthRequirement;

  /// Requisito de validação de letra maiúscula na senha
  ///
  /// In pt, this message translates to:
  /// **'Pelo menos 1 letra maiúscula'**
  String get passwordUppercaseRequirement;

  /// Requisito de validação de letra minúscula na senha
  ///
  /// In pt, this message translates to:
  /// **'Pelo menos 1 letra minúscula'**
  String get passwordLowercaseRequirement;

  /// Requisito de validação de número na senha
  ///
  /// In pt, this message translates to:
  /// **'Pelo menos 1 número'**
  String get passwordNumberRequirement;

  /// Indicador de que as senhas digitadas são iguais
  ///
  /// In pt, this message translates to:
  /// **'Senhas conferem'**
  String get passwordsMatchRequirement;

  /// Botão para submeter o cadastro
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar'**
  String get registerButton;

  /// Link para quem já possui conta e quer ir para o login
  ///
  /// In pt, this message translates to:
  /// **'Já tenho uma conta'**
  String get alreadyHaveAccountLink;

  /// Título da tela de vinculação de perfil por token
  ///
  /// In pt, this message translates to:
  /// **'Vincular Perfil'**
  String get claimTokenTitle;

  /// Mensagem de sucesso após vincular perfil com token
  ///
  /// In pt, this message translates to:
  /// **'Perfil vinculado com sucesso!'**
  String get claimTokenSuccessMessage;

  /// Cabeçalho de instrução para digitação do token de acesso
  ///
  /// In pt, this message translates to:
  /// **'Informe o seu Token de Acesso'**
  String get claimTokenInputHeader;

  /// Descrição detalhada sobre a digitação do token de acesso
  ///
  /// In pt, this message translates to:
  /// **'Digite o token fornecido após a aprovação para vincular sua conta.'**
  String get claimTokenInputDescription;

  /// Rótulo do campo de entrada de token
  ///
  /// In pt, this message translates to:
  /// **'Claim Token'**
  String get claimTokenFieldLabel;

  /// Exemplo/Dica para preenchimento do token de acesso
  ///
  /// In pt, this message translates to:
  /// **'Ex: 1A2B3C4D'**
  String get claimTokenFieldHint;

  /// Erro exibido ao tentar enviar o token em branco
  ///
  /// In pt, this message translates to:
  /// **'Por favor, informe o token de acesso.'**
  String get claimTokenRequiredError;

  /// Tooltip do botão de logout no app bar
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get logoutTooltip;

  /// Texto do botão principal de sair da conta
  ///
  /// In pt, this message translates to:
  /// **'Sair da Conta'**
  String get logoutButton;

  /// Nome genérico exibido quando o usuário não possui nome cadastrado
  ///
  /// In pt, this message translates to:
  /// **'Usuária'**
  String get defaultUserName;

  /// Badge de status de perfil ativado
  ///
  /// In pt, this message translates to:
  /// **'Perfil Vinculado & Ativo'**
  String get profileStatusActive;

  /// Título da seção de dados do perfil na home
  ///
  /// In pt, this message translates to:
  /// **'Dados do Perfil Cadastrado'**
  String get profileDataSectionTitle;

  /// Rótulo do item de perfil para o nome completo
  ///
  /// In pt, this message translates to:
  /// **'Nome Completo'**
  String get fullNameLabel;

  /// Rótulo do item de perfil para número de telefone
  ///
  /// In pt, this message translates to:
  /// **'Telefone'**
  String get phoneLabel;

  /// Rótulo do item de perfil para endereço
  ///
  /// In pt, this message translates to:
  /// **'Endereço'**
  String get addressLabel;

  /// Rótulo do item de perfil para data de nascimento
  ///
  /// In pt, this message translates to:
  /// **'Data de Nascimento'**
  String get birthdayLabel;

  /// Rótulo do item de perfil para conta do instagram
  ///
  /// In pt, this message translates to:
  /// **'Instagram'**
  String get instagramLabel;

  /// Rótulo do item de perfil para grau de escolaridade
  ///
  /// In pt, this message translates to:
  /// **'Escolaridade'**
  String get educationLabel;

  /// Rótulo do item de perfil para cargo ou profissão
  ///
  /// In pt, this message translates to:
  /// **'Cargo / Profissão'**
  String get jobPositionLabel;

  /// Rótulo do item de perfil para ID do usuário no Supabase
  ///
  /// In pt, this message translates to:
  /// **'ID Auth (Supabase User ID)'**
  String get authUserIdLabel;
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
