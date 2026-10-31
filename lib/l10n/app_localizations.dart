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

  /// Texto padrão para ação de fechar
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get close;

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

  /// Mensagem exibida após o cadastro bem-sucedido
  ///
  /// In pt, this message translates to:
  /// **'Conta criada com sucesso! Verifique seu e-mail para confirmar a conta.'**
  String get accountCreatedSuccessMessage;

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

  /// Mensagem amigável de erro quando o token de acesso é inválido ou já foi utilizado
  ///
  /// In pt, this message translates to:
  /// **'Token de acesso inválido ou já utilizado. Por favor, verifique o código.'**
  String get claimTokenInvalidError;

  /// Mensagem genérica amigável para falhas inesperadas de rede ou servidor
  ///
  /// In pt, this message translates to:
  /// **'Ocorreu um erro ao processar sua solicitação. Tente novamente mais tarde.'**
  String get genericError;

  /// Texto padrão para ação de retornar
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get back;

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

  /// Rótulo de acessibilidade para o botão de logout no perfil
  ///
  /// In pt, this message translates to:
  /// **'Sair da conta'**
  String get profileLogoutButtonLabel;

  /// Título do modal de confirmação de logout
  ///
  /// In pt, this message translates to:
  /// **'Sair da conta'**
  String get logoutDialogTitle;

  /// Mensagem do modal de confirmação de logout
  ///
  /// In pt, this message translates to:
  /// **'Você deseja mesmo sair do aplicativo? Será necessário fazer login novamente para acessar sua conta.'**
  String get logoutDialogMessage;

  /// Botão de cancelar no modal de logout
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get logoutDialogCancel;

  /// Botão de confirmar no modal de logout
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get logoutDialogConfirm;

  /// No description provided for @meetingEditTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar encontro'**
  String get meetingEditTitle;

  /// No description provided for @meetingEditDateLabel.
  ///
  /// In pt, this message translates to:
  /// **'Data'**
  String get meetingEditDateLabel;

  /// No description provided for @meetingEditDateHint.
  ///
  /// In pt, this message translates to:
  /// **'DD/MM/AAAA'**
  String get meetingEditDateHint;

  /// No description provided for @meetingEditDateError.
  ///
  /// In pt, this message translates to:
  /// **'Informe a data.'**
  String get meetingEditDateError;

  /// No description provided for @meetingEditTimeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Horário'**
  String get meetingEditTimeLabel;

  /// No description provided for @meetingEditTimeHint.
  ///
  /// In pt, this message translates to:
  /// **'HH:MM'**
  String get meetingEditTimeHint;

  /// No description provided for @meetingEditTimeError.
  ///
  /// In pt, this message translates to:
  /// **'Informe o horário.'**
  String get meetingEditTimeError;

  /// No description provided for @meetingEditLocationLabel.
  ///
  /// In pt, this message translates to:
  /// **'Local'**
  String get meetingEditLocationLabel;

  /// No description provided for @meetingEditLocationHint.
  ///
  /// In pt, this message translates to:
  /// **'Nome do local'**
  String get meetingEditLocationHint;

  /// No description provided for @meetingEditLocationError.
  ///
  /// In pt, this message translates to:
  /// **'Informe o local.'**
  String get meetingEditLocationError;

  /// No description provided for @meetingEditLocationSelectError.
  ///
  /// In pt, this message translates to:
  /// **'Selecione um local da lista.'**
  String get meetingEditLocationSelectError;

  /// No description provided for @meetingEditLocationSearchError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível buscar locais. Tente novamente.'**
  String get meetingEditLocationSearchError;

  /// No description provided for @meetingEditDateInvalidError.
  ///
  /// In pt, this message translates to:
  /// **'Informe uma data válida (DD/MM/AAAA).'**
  String get meetingEditDateInvalidError;

  /// No description provided for @meetingEditTimeInvalidError.
  ///
  /// In pt, this message translates to:
  /// **'Informe um horário válido (HH:MM).'**
  String get meetingEditTimeInvalidError;

  /// No description provided for @meetingEditDescriptionLabel.
  ///
  /// In pt, this message translates to:
  /// **'Observações'**
  String get meetingEditDescriptionLabel;

  /// No description provided for @meetingEditDescriptionHint.
  ///
  /// In pt, this message translates to:
  /// **'Adicione observações (opcional)'**
  String get meetingEditDescriptionHint;

  /// No description provided for @meetingEditReadOnlySection.
  ///
  /// In pt, this message translates to:
  /// **'Informações definidas pelo sorteio'**
  String get meetingEditReadOnlySection;

  /// No description provided for @meetingEditBookLabel.
  ///
  /// In pt, this message translates to:
  /// **'Livro da vez'**
  String get meetingEditBookLabel;

  /// No description provided for @meetingEditHostLabel.
  ///
  /// In pt, this message translates to:
  /// **'Anfitriã'**
  String get meetingEditHostLabel;

  /// No description provided for @meetingEditSaveButton.
  ///
  /// In pt, this message translates to:
  /// **'Salvar alterações'**
  String get meetingEditSaveButton;

  /// Rótulo de acessibilidade da foto de capa do encontro
  ///
  /// In pt, this message translates to:
  /// **'Foto do {title}'**
  String meetingCoverSemanticLabel(String title);

  /// Anfitriã do encontro
  ///
  /// In pt, this message translates to:
  /// **'Anfitriã: {name}'**
  String meetingDetailsHost(String name);

  /// Nome e endereço do local do encontro
  ///
  /// In pt, this message translates to:
  /// **'Local: {location}'**
  String meetingDetailsLocation(String location);

  /// Exibido quando o encontro ainda não tem local
  ///
  /// In pt, this message translates to:
  /// **'Local: a definir'**
  String get meetingDetailsLocationUndefined;

  /// Título da seção de descrição do encontro
  ///
  /// In pt, this message translates to:
  /// **'Descrição'**
  String get meetingDetailsDescriptionTitle;

  /// No description provided for @meetingDetailsOpenMapHint.
  ///
  /// In pt, this message translates to:
  /// **'Abrir no Google Maps'**
  String get meetingDetailsOpenMapHint;

  /// No description provided for @meetingDetailsMapLaunchError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir o mapa.'**
  String get meetingDetailsMapLaunchError;

  /// Título da seção de fotos na tela de detalhes do encontro
  ///
  /// In pt, this message translates to:
  /// **'Fotos do encontro'**
  String get meetingPhotosTitle;

  /// Texto do estado vazio da seção de fotos; ao tocar abre a galeria
  ///
  /// In pt, this message translates to:
  /// **'Adicionar fotos'**
  String get meetingPhotosAdd;

  /// Rótulo de acessibilidade do botão de adicionar fotos ao final da galeria
  ///
  /// In pt, this message translates to:
  /// **'Adicionar mais fotos'**
  String get meetingPhotosAddMoreSemanticLabel;

  /// Rótulo de acessibilidade de uma miniatura da galeria do encontro
  ///
  /// In pt, this message translates to:
  /// **'Foto {index} do encontro'**
  String meetingPhotoSemanticLabel(int index);

  /// Progresso do envio das fotos selecionadas
  ///
  /// In pt, this message translates to:
  /// **'Enviando {current} de {total}'**
  String meetingPhotosUploading(int current, int total);

  /// Mensagem exibida quando parte das fotos não foi enviada
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Não foi possível enviar 1 foto.} other{Não foi possível enviar {count} fotos.}}'**
  String meetingPhotosUploadFailed(int count);

  /// Ação para reenviar só as fotos que falharam ou recarregar a galeria
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get meetingPhotosRetryButton;

  /// Erro ao carregar a galeria do encontro
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar as fotos do encontro.'**
  String get meetingPhotosLoadError;

  /// Encontro sem fotos, para quem não pode adicionar (nem coordenadora nem anfitriã)
  ///
  /// In pt, this message translates to:
  /// **'Ainda não há fotos deste encontro.'**
  String get meetingPhotosEmpty;

  /// Exibido quando o acesso à galeria foi negado
  ///
  /// In pt, this message translates to:
  /// **'Permita o acesso às fotos nos ajustes do aparelho para adicionar fotos.'**
  String get meetingPhotosAccessDenied;

  /// Exibido quando a galeria não abre por um erro inesperado
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir a galeria. Tente novamente.'**
  String get meetingPhotosPickerFailed;

  /// Fotos descartadas antes do envio por tamanho ou formato
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 foto foi ignorada: passa de 5 MB ou o formato não é aceito.} other{{count} fotos foram ignoradas: passam de 5 MB ou o formato não é aceito.}}'**
  String meetingPhotosSkipped(int count);

  /// Exibido quando o encontro atingiu o limite de fotos
  ///
  /// In pt, this message translates to:
  /// **'Este encontro já tem o máximo de {max} fotos.'**
  String meetingPhotosLimitReached(int max);

  /// Fotos recusadas pelo servidor (sem nova tentativa), por exemplo tamanho, formato ou permissão
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 foto foi recusada e não pode ser enviada.} other{{count} fotos foram recusadas e não podem ser enviadas.}}'**
  String meetingPhotosRejected(int count);

  /// Título principal do review de cadastro
  ///
  /// In pt, this message translates to:
  /// **'Verifique os seus dados'**
  String get onboardingReviewTitle;

  /// Rótulo do campo Nome
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get onboardingNameLabel;

  /// Rótulo e-mail
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get onboardingEmailLabel;

  /// Rótulo celular
  ///
  /// In pt, this message translates to:
  /// **'Celular'**
  String get onboardingPhoneLabel;

  /// Rótulo data de nascimento
  ///
  /// In pt, this message translates to:
  /// **'Data de nascimento'**
  String get onboardingBirthDateLabel;

  /// Rótulo cidade
  ///
  /// In pt, this message translates to:
  /// **'Cidade'**
  String get onboardingCityLabel;

  /// Dica de seleção de cidade
  ///
  /// In pt, this message translates to:
  /// **'Selecione uma cidade'**
  String get onboardingCityHint;

  /// Rótulo região
  ///
  /// In pt, this message translates to:
  /// **'Região'**
  String get onboardingRegionLabel;

  /// Rótulo profissão
  ///
  /// In pt, this message translates to:
  /// **'Qual sua profissão?'**
  String get onboardingJobLabel;

  /// Rótulo escolaridade
  ///
  /// In pt, this message translates to:
  /// **'Nível de escolaridade'**
  String get onboardingEducationLabel;

  /// Dica seleção de escolaridade
  ///
  /// In pt, this message translates to:
  /// **'Selecione um nível'**
  String get onboardingEducationHint;

  /// Rótulo grupo de leitura
  ///
  /// In pt, this message translates to:
  /// **'Você participa de outro grupo de leitura?'**
  String get onboardingOtherGroupLabel;

  /// Rótulo voluntariado
  ///
  /// In pt, this message translates to:
  /// **'Teria interesse em se voluntariar como coordenadora de grupo?'**
  String get onboardingVolunteerLabel;

  /// Rótulo indicação livro
  ///
  /// In pt, this message translates to:
  /// **'Qual livro de ficção você indicaria para a leitura coletiva?'**
  String get onboardingBookIndicationLabel;

  /// Dica indicação livro
  ///
  /// In pt, this message translates to:
  /// **'Digite sua resposta'**
  String get onboardingBookIndicationHint;

  /// Rótulo expectativas
  ///
  /// In pt, this message translates to:
  /// **'O que você espera ao participar do Clube de Leitura D\'Elas?'**
  String get onboardingExpectationsLabel;

  /// Dica expectativas
  ///
  /// In pt, this message translates to:
  /// **'Digite sua resposta'**
  String get onboardingExpectationsHint;

  /// Botão voltar
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get onboardingBackButton;

  /// Botão continuar
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get onboardingContinueButton;

  /// Título de boas-vindas
  ///
  /// In pt, this message translates to:
  /// **'Seja Bem-vinda'**
  String get onboardingWelcomeTitle;

  /// Subtítulo de boas-vindas
  ///
  /// In pt, this message translates to:
  /// **'Sua inscrição foi realizada com sucesso!'**
  String get onboardingWelcomeSubtitle;

  /// Botão concluir onboarding
  ///
  /// In pt, this message translates to:
  /// **'Pronta para o próximo capítulo?'**
  String get onboardingWelcomeButton;

  /// Dica genérica de seleção em dropdown
  ///
  /// In pt, this message translates to:
  /// **'Selecione'**
  String get selectOptionHint;

  /// Opção de gênero literário Romance usada nos testes/demonstrações do Dropdown
  ///
  /// In pt, this message translates to:
  /// **'Romance'**
  String get genreRomance;

  /// Opção de gênero literário Fantasia usada nos testes/demonstrações do Dropdown
  ///
  /// In pt, this message translates to:
  /// **'Fantasia'**
  String get genreFantasy;

  /// Opção de gênero literário Suspense usada nos testes/demonstrações do Dropdown
  ///
  /// In pt, this message translates to:
  /// **'Suspense'**
  String get genreSuspense;

  /// Opção de gênero literário Não Ficção usada nos testes/demonstrações do Dropdown
  ///
  /// In pt, this message translates to:
  /// **'Não Ficção'**
  String get genreNonFiction;

  /// Texto de dica para seleção de gênero usada nos testes/demonstrações do Dropdown
  ///
  /// In pt, this message translates to:
  /// **'Selecione um gênero'**
  String get genreFieldHint;

  /// Título principal da tela de grupos
  ///
  /// In pt, this message translates to:
  /// **'Meus grupos'**
  String get myGroupsTitle;

  /// Placeholder do campo de busca de grupos
  ///
  /// In pt, this message translates to:
  /// **'Buscar grupo'**
  String get searchGroupPlaceholder;

  /// Aviso na home quando a anfitriã tem tarefas pendentes
  ///
  /// In pt, this message translates to:
  /// **'Você tem tarefas pendentes'**
  String get homePendingTasksMessage;

  /// Botão do aviso de tarefas pendentes que abre as tarefas da anfitriã
  ///
  /// In pt, this message translates to:
  /// **'Tarefas'**
  String get homePendingTasksAction;

  /// Título da tela com os grupos em que a anfitriã tem tarefas pendentes
  ///
  /// In pt, this message translates to:
  /// **'Tarefas pendentes'**
  String get pendingTasksTitle;

  /// Mensagem exibida quando não há grupos com tarefas pendentes
  ///
  /// In pt, this message translates to:
  /// **'Você não tem tarefas pendentes'**
  String get emptyPendingTasks;

  /// Título exibido quando a lista de grupos está vazia
  ///
  /// In pt, this message translates to:
  /// **'Você ainda não participa de nenhum grupo'**
  String get emptyGroupsTitle;

  /// Mensagem detalhada exibida quando a lista de grupos está vazia
  ///
  /// In pt, this message translates to:
  /// **'Assim que você entrar em um grupo de leitura, ele aparecerá aqui.'**
  String get emptyGroupsMessage;

  /// Mensagem exibida quando a busca por nome não retorna grupos
  ///
  /// In pt, this message translates to:
  /// **'Nenhum grupo encontrado'**
  String get emptyGroupsSearch;

  /// Título da tela de detalhes do grupo, com o número do grupo
  ///
  /// In pt, this message translates to:
  /// **'Grupo {number}'**
  String groupDetailsNumberLabel(int number);

  /// Título da seção do próximo evento nos detalhes do grupo
  ///
  /// In pt, this message translates to:
  /// **'Próximo evento'**
  String get groupNextEventTitle;

  /// Mensagem exibida quando o grupo não possui próximo evento
  ///
  /// In pt, this message translates to:
  /// **'Nenhum próximo evento agendado'**
  String get groupNextEventEmpty;

  /// Nome da anfitriã do próximo evento
  ///
  /// In pt, this message translates to:
  /// **'Anfitriã: {name}'**
  String groupNextEventHost(String name);

  /// Link exibido abaixo da seção de participantes para acessar o histórico de encontros
  ///
  /// In pt, this message translates to:
  /// **'Histórico de eventos'**
  String get groupNextEventHistoryLink;

  /// Link exibido abaixo do próximo evento para abrir os detalhes daquele encontro
  ///
  /// In pt, this message translates to:
  /// **'Exibir mais detalhes'**
  String get groupNextEventMoreDetailsLink;

  /// Rótulo exibido acima da capa do livro do próximo evento do grupo
  ///
  /// In pt, this message translates to:
  /// **'O livro da vez é:'**
  String get groupNextEventCurrentBookLabel;

  /// Rótulo de acessibilidade da capa do livro do próximo evento
  ///
  /// In pt, this message translates to:
  /// **'Capa do livro {title}'**
  String groupNextEventBookCoverSemanticLabel(String title);

  /// Exibido no lugar da capa quando o próximo evento ainda não tem livro definido
  ///
  /// In pt, this message translates to:
  /// **'Livro ainda não definido'**
  String get groupNextEventBookUndefined;

  /// Exibido no próximo evento do grupo quando nenhum local foi definido
  ///
  /// In pt, this message translates to:
  /// **'Sem localização'**
  String get groupNextEventNoLocation;

  /// Título da seção de participantes nos detalhes do grupo
  ///
  /// In pt, this message translates to:
  /// **'Participantes'**
  String get groupParticipantsTitle;

  /// Quantidade de participantes do grupo
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{Nenhum participante} =1{1 participante} other{{count} participantes}}'**
  String groupParticipantsCount(int count);

  /// Botão para abrir o grupo no WhatsApp
  ///
  /// In pt, this message translates to:
  /// **'Abrir Whatsapp'**
  String get groupOpenWhatsAppButton;

  /// Mensagem de erro exibida quando falha a abertura do link do WhatsApp
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir o link do WhatsApp.'**
  String get whatsappLaunchError;

  /// Botão para indicar um livro ao grupo
  ///
  /// In pt, this message translates to:
  /// **'Indicar livro'**
  String get groupRecommendBookButton;

  /// Descrição acessível da foto de capa do grupo
  ///
  /// In pt, this message translates to:
  /// **'Foto do grupo {name}'**
  String groupCoverSemanticLabel(String name);

  /// Mensagem quando o grupo não tem participantes
  ///
  /// In pt, this message translates to:
  /// **'Ainda não há participantes neste grupo.'**
  String get groupParticipantsEmpty;

  /// Erro ao buscar a lista de participantes do grupo
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar as participantes.'**
  String get groupParticipantsLoadError;

  /// Botão para buscar de novo a lista de participantes após erro
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get groupParticipantsRetryButton;

  /// Rótulo acessível do estado de carregamento da lista de participantes
  ///
  /// In pt, this message translates to:
  /// **'Carregando participantes'**
  String get groupParticipantsLoading;

  /// Rótulo da seção de próximo encontro no card de grupo
  ///
  /// In pt, this message translates to:
  /// **'Próximo evento'**
  String get groupNextMeetingLabel;

  /// Botão para recusar presença no próximo encontro do grupo
  ///
  /// In pt, this message translates to:
  /// **'Não irei'**
  String get groupDeclineMeetingButton;

  /// Botão para confirmar presença no próximo encontro do grupo
  ///
  /// In pt, this message translates to:
  /// **'Confirmar presença'**
  String get groupConfirmMeetingButton;

  /// Rótulo exibido acima do botão 'Não irei' quando a presença no próximo encontro já foi confirmada
  ///
  /// In pt, this message translates to:
  /// **'Presença confirmada'**
  String get groupMeetingConfirmedLabel;

  /// Rótulo exibido acima do botão 'Confirmar presença' quando a ausência no próximo encontro já foi confirmada
  ///
  /// In pt, this message translates to:
  /// **'Ausência confirmada'**
  String get groupMeetingDeclinedLabel;

  /// Tentar responder a confirmação de presença no encontro novamente após um erro
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get groupMeetingRsvpRetryAction;

  /// Título da tela de histórico de eventos do grupo
  ///
  /// In pt, this message translates to:
  /// **'Histórico de eventos'**
  String get groupEventHistoryTitle;

  /// Identificação da anfitriã de um evento realizado
  ///
  /// In pt, this message translates to:
  /// **'Anfitriã: {hostName}'**
  String groupEventHistoryHost(String hostName);

  /// Link para abrir os detalhes de um evento realizado
  ///
  /// In pt, this message translates to:
  /// **'Confira mais detalhes'**
  String get groupEventHistoryDetailsLink;

  /// Rótulo do botão e título da tela de tarefas da anfitriã ou coordenadora do encontro
  ///
  /// In pt, this message translates to:
  /// **'Minhas tarefas'**
  String get groupMeetingMyTasksAction;

  /// Mensagem exibida quando o grupo não possui encontros realizados
  ///
  /// In pt, this message translates to:
  /// **'Este grupo ainda não realizou encontros.'**
  String get groupEventHistoryEmpty;

  /// Título do cabeçalho da tela de detalhes do encontro enquanto carrega ou em erro
  ///
  /// In pt, this message translates to:
  /// **'Detalhes do encontro'**
  String get meetingDetailsHeader;

  /// Título do encontro com a numeração sequencial no grupo
  ///
  /// In pt, this message translates to:
  /// **'Encontro {number}'**
  String meetingDetailsTitle(int number);

  /// Título do encontro quando ele ainda não tem numeração (sem data)
  ///
  /// In pt, this message translates to:
  /// **'Encontro'**
  String get meetingDetailsTitleFallback;

  /// Data do encontro já formatada
  ///
  /// In pt, this message translates to:
  /// **'Data: {date}'**
  String meetingDetailsDate(String date);

  /// Exibido quando o encontro ainda não tem data
  ///
  /// In pt, this message translates to:
  /// **'Data: a definir'**
  String get meetingDetailsDateUndefined;

  /// Livro lido no encontro
  ///
  /// In pt, this message translates to:
  /// **'Livro: {title}'**
  String meetingDetailsBook(String title);

  /// Título exibido quando uma reunião não possui participantes.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum participante nesta reunião'**
  String get meetingPresenceEmptyTitle;

  /// Descrição exibida no estado vazio da tela de presença.
  ///
  /// In pt, this message translates to:
  /// **'Quando houver participantes, eles aparecerão aqui para registrar a presença.'**
  String get meetingPresenceEmptyDescription;

  /// No description provided for @meetingEditAction.
  ///
  /// In pt, this message translates to:
  /// **'Editar encontro'**
  String get meetingEditAction;

  /// No description provided for @meetingPresenceHeader.
  ///
  /// In pt, this message translates to:
  /// **'Lista de Presença'**
  String get meetingPresenceHeader;

  /// Indicação exibida após o registro da presença do encontro
  ///
  /// In pt, this message translates to:
  /// **'Presença confirmada'**
  String get meetingPresenceConfirmed;

  /// Indicação exibida na lista de presença para a participante marcada
  ///
  /// In pt, this message translates to:
  /// **'Presente'**
  String get meetingPresencePresent;

  /// Indicação exibida na lista de presença para a participante desmarcada
  ///
  /// In pt, this message translates to:
  /// **'Ausente'**
  String get meetingPresenceAbsent;

  /// No description provided for @invitationConfirmed.
  ///
  /// In pt, this message translates to:
  /// **'Confirmou presença'**
  String get invitationConfirmed;

  /// No description provided for @invitationNoResponse.
  ///
  /// In pt, this message translates to:
  /// **'Sem resposta'**
  String get invitationNoResponse;

  /// No description provided for @invitationDeclined.
  ///
  /// In pt, this message translates to:
  /// **'Recusou o convite'**
  String get invitationDeclined;

  /// Título principal da tela de preparação do sorteio
  ///
  /// In pt, this message translates to:
  /// **'Realizar sorteio'**
  String get rafflePreparationTitle;

  /// Subtítulo de instrução da tela de preparação do sorteio
  ///
  /// In pt, this message translates to:
  /// **'Selecione as participantes'**
  String get rafflePreparationSubtitle;

  /// Rótulo do cabeçalho de nome na tabela de participantes
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get raffleTableHeaderName;

  /// Rótulo do cabeçalho de seleção/presença na tabela de participantes
  ///
  /// In pt, this message translates to:
  /// **'Incluir no sorteio'**
  String get raffleTableHeaderInclude;

  /// Título da caixa de diálogo de confirmação do sorteio
  ///
  /// In pt, this message translates to:
  /// **'Confirmar sorteio'**
  String get raffleConfirmDialogTitle;

  /// Mensagem de confirmação na caixa de diálogo do sorteio
  ///
  /// In pt, this message translates to:
  /// **'Você deseja mesmo confirmar o sorteio?'**
  String get raffleConfirmDialogMessage;

  /// Texto do botão de cancelamento na caixa de diálogo do sorteio
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get raffleConfirmDialogCancel;

  /// Título no header da tela de realização do sorteio
  ///
  /// In pt, this message translates to:
  /// **'Realizar Sorteio'**
  String get raffleDrawScreenTitle;

  /// Título principal com o mês do sorteio do livro
  ///
  /// In pt, this message translates to:
  /// **'Sorteio do Livro - {month}'**
  String raffleBookDrawTitle(String month);

  /// Texto do botão central principal para realizar o sorteio
  ///
  /// In pt, this message translates to:
  /// **'SORTEAR'**
  String get raffleDrawButton;

  /// Texto informativo no rodapé sobre a aleatoriedade do sorteio
  ///
  /// In pt, this message translates to:
  /// **'O sorteio é automático e aleatório.\nA participação é voluntária.'**
  String get raffleDisclaimer;

  /// Título do cabeçalho da tela de resultado do sorteio
  ///
  /// In pt, this message translates to:
  /// **'Resultado do Sorteio'**
  String get raffleResultTitle;

  /// Rótulo superior acima do livro sorteado
  ///
  /// In pt, this message translates to:
  /// **'Livro sorteado'**
  String get raffleDrawnBookLabel;

  /// Rótulo identificando a anfitriã sorteada
  ///
  /// In pt, this message translates to:
  /// **'Anfitriã'**
  String get raffleHostLabel;

  /// Frase anunciando a anfitriã da vez
  ///
  /// In pt, this message translates to:
  /// **'A Anfitriã da vez é'**
  String get raffleHostAnnounceLabel;

  /// Texto do botão principal de concluir e registrar o resultado
  ///
  /// In pt, this message translates to:
  /// **'Concluir'**
  String get raffleFinishButton;

  /// Texto do botão secundário para sortear novamente
  ///
  /// In pt, this message translates to:
  /// **'Sortear novamente'**
  String get raffleDrawAgainButton;

  /// Mensagem exibida quando alguma etapa do sorteio falha
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível concluir o sorteio'**
  String get raffleErrorMessage;

  /// Aviso abaixo do botão de sortear novamente quando todas as participantes já foram sorteadas
  ///
  /// In pt, this message translates to:
  /// **'Sem mais pessoas para sortear'**
  String get raffleNoMoreParticipantsToDraw;

  /// Aviso emitido quando a lista de participantes elegíveis está vazia
  ///
  /// In pt, this message translates to:
  /// **'Não há participantes elegíveis para o sorteio.'**
  String get raffleNoEligibleParticipants;

  /// Mensagem de sucesso após registrar o sorteio e definir a nova anfitriã
  ///
  /// In pt, this message translates to:
  /// **'Sorteio registrado com sucesso! Nova anfitriã definida.'**
  String get raffleSavedSuccessToast;

  /// Descrição de acessibilidade do contador de tarefas da anfitriã no card do grupo
  ///
  /// In pt, this message translates to:
  /// **'{done} de {total} tarefas concluídas'**
  String groupMeetingMyTasksProgress(int done, int total);

  /// Título da tela de tarefas da anfitriã
  ///
  /// In pt, this message translates to:
  /// **'Suas tarefas'**
  String get meetingTasksTitle;

  /// Mensagem quando a tela de tarefas é aberta sem meeting_id
  ///
  /// In pt, this message translates to:
  /// **'Encontro inválido.'**
  String get meetingTasksInvalidMeeting;

  /// Botão para recarregar as tarefas após erro
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get meetingTasksRetry;

  /// Sobretítulo do banner antes de o encontro ser publicado
  ///
  /// In pt, this message translates to:
  /// **'VOCÊ FOI SORTEADA'**
  String get meetingTasksDrawnLabel;

  /// Título do banner quando o livro do encontro não é conhecido
  ///
  /// In pt, this message translates to:
  /// **'Próximo encontro'**
  String get meetingTasksDrawnFallbackTitle;

  /// Sobretítulo do banner depois de o encontro ser publicado
  ///
  /// In pt, this message translates to:
  /// **'TUDO CERTO'**
  String get meetingTasksPublishedLabel;

  /// Título do banner depois de o encontro ser publicado
  ///
  /// In pt, this message translates to:
  /// **'Encontro publicado'**
  String get meetingTasksPublishedTitle;

  /// Mensagem do banner depois de o encontro ser publicado
  ///
  /// In pt, this message translates to:
  /// **'As participantes já foram avisadas.'**
  String get meetingTasksPublishedMessage;

  /// Quantidade de tarefas pendentes da anfitriã
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{Todas as tarefas concluídas} =1{1 tarefa para você} other{{count} tarefas para você}}'**
  String meetingTasksPendingCount(int count);

  /// Título da tarefa de marcar data e local
  ///
  /// In pt, this message translates to:
  /// **'1. Marcar data e local'**
  String get meetingTasksScheduleTitle;

  /// Descrição da tarefa de marcar data e local enquanto pendente
  ///
  /// In pt, this message translates to:
  /// **'O grupo está esperando para saber quando e onde.'**
  String get meetingTasksSchedulePending;

  /// Botão que abre a edição do encontro
  ///
  /// In pt, this message translates to:
  /// **'Marcar agora'**
  String get meetingTasksScheduleAction;

  /// Tooltip e rótulo de acessibilidade do botão de editar data e local no card de tarefas do encontro
  ///
  /// In pt, this message translates to:
  /// **'Editar data e local'**
  String get meetingTasksScheduleEditAction;

  /// Título da tarefa de enviar fotos e registro do encontro
  ///
  /// In pt, this message translates to:
  /// **'2. Enviar fotos do encontro'**
  String get meetingTasksRecordTitle;

  /// Descrição da tarefa de fotos antes de o encontro ser encerrado
  ///
  /// In pt, this message translates to:
  /// **'Disponível depois que o encontro acontecer.'**
  String get meetingTasksRecordLocked;

  /// Descrição da tarefa de fotos quando disponível
  ///
  /// In pt, this message translates to:
  /// **'Depois do encontro, compartilhe como foi.'**
  String get meetingTasksRecordPending;

  /// Descrição da tarefa de fotos quando há rascunho salvo
  ///
  /// In pt, this message translates to:
  /// **'Você tem um rascunho salvo. Continue de onde parou.'**
  String get meetingTasksRecordDraft;

  /// Etiqueta que indica rascunho salvo na tarefa de fotos
  ///
  /// In pt, this message translates to:
  /// **'Rascunho salvo'**
  String get meetingTasksRecordDraftTag;

  /// Descrição da tarefa de fotos depois de publicada
  ///
  /// In pt, this message translates to:
  /// **'Registro publicado.'**
  String get meetingTasksRecordPublished;

  /// Botão que abre a tela de fotos e registro do encontro
  ///
  /// In pt, this message translates to:
  /// **'Enviar fotos'**
  String get meetingTasksRecordAction;

  /// Descrição de acessibilidade do ícone de tarefa concluída
  ///
  /// In pt, this message translates to:
  /// **'Concluída'**
  String get meetingTasksDoneSemantics;

  /// Botão de encerrar o encontro no rodapé das tarefas
  ///
  /// In pt, this message translates to:
  /// **'Encerrar encontro'**
  String get meetingTasksConcludeAction;

  /// Aviso acima do botão de encerrar enquanto ele está bloqueado
  ///
  /// In pt, this message translates to:
  /// **'Este botão ficará ativo quando o encontro iniciar.'**
  String get meetingTasksConcludeHint;

  /// Título do modal de confirmação de encerramento
  ///
  /// In pt, this message translates to:
  /// **'Encerrar encontro'**
  String get meetingTasksConcludeDialogTitle;

  /// Mensagem do modal de confirmação de encerramento
  ///
  /// In pt, this message translates to:
  /// **'Você deseja mesmo encerrar o encontro? Para concluir, preencha a lista de presença.'**
  String get meetingTasksConcludeDialogMessage;

  /// Botão que cancela o encerramento
  ///
  /// In pt, this message translates to:
  /// **'Não'**
  String get meetingTasksConcludeDialogNo;

  /// Botão que confirma o encerramento e abre a lista de presença
  ///
  /// In pt, this message translates to:
  /// **'Sim'**
  String get meetingTasksConcludeDialogYes;

  /// Botão que conclui a lista de presença e encerra o encontro
  ///
  /// In pt, this message translates to:
  /// **'Concluir lista de presença'**
  String get meetingAttendanceCompleteAction;

  /// Tooltip e acessibilidade para exibir senha
  ///
  /// In pt, this message translates to:
  /// **'Mostrar senha'**
  String get showPasswordTooltip;

  /// Tooltip e acessibilidade para ocultar senha
  ///
  /// In pt, this message translates to:
  /// **'Ocultar senha'**
  String get hidePasswordTooltip;

  /// Descrição de acessibilidade do logotipo do aplicativo
  ///
  /// In pt, this message translates to:
  /// **'Logo do Clube de Leitura D\'Elas'**
  String get appLogoSemanticLabel;

  /// Título do visualizador de fotos do encontro.
  ///
  /// In pt, this message translates to:
  /// **'Foto {index} de {total}'**
  String meetingPhotoViewerTitle(int index, int total);

  /// Rótulo de acessibilidade para abrir a foto em tela cheia.
  ///
  /// In pt, this message translates to:
  /// **'Abrir foto {index} do encontro'**
  String meetingPhotoOpenSemanticLabel(int index);

  /// Ação para baixar a foto do encontro.
  ///
  /// In pt, this message translates to:
  /// **'Baixar'**
  String get meetingPhotoDownload;

  /// Erro ao abrir a foto para download.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir a foto para baixar.'**
  String get meetingPhotoDownloadFailed;

  /// Ação para remover a foto do encontro.
  ///
  /// In pt, this message translates to:
  /// **'Remover'**
  String get meetingPhotoDelete;

  /// Título da confirmação de remoção de foto.
  ///
  /// In pt, this message translates to:
  /// **'Remover foto'**
  String get meetingPhotoDeleteDialogTitle;

  /// Mensagem da confirmação de remoção de foto.
  ///
  /// In pt, this message translates to:
  /// **'A foto deixa de aparecer no encontro. Deseja remover?'**
  String get meetingPhotoDeleteDialogMessage;

  /// Botão que cancela a remoção da foto.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get meetingPhotoDeleteDialogCancel;

  /// Aviso de foto removida.
  ///
  /// In pt, this message translates to:
  /// **'Foto removida.'**
  String get meetingPhotoDeleted;

  /// Erro ao remover a foto.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível remover a foto. Tente novamente.'**
  String get meetingPhotoDeleteFailed;

  /// Título do bloco de texto de divulgação do encontro.
  ///
  /// In pt, this message translates to:
  /// **'Texto de divulgação'**
  String get meetingPromoTextTitle;

  /// Texto exibido quando o encontro não tem texto de divulgação.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum texto de divulgação anexado.'**
  String get meetingPromoTextEmpty;

  /// Botão para anexar o texto de divulgação.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar texto'**
  String get meetingPromoTextAdd;

  /// Botão para editar o texto de divulgação.
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get meetingPromoTextEdit;

  /// Botão para copiar o texto de divulgação.
  ///
  /// In pt, this message translates to:
  /// **'Copiar'**
  String get meetingPromoTextCopy;

  /// Aviso de texto de divulgação copiado.
  ///
  /// In pt, this message translates to:
  /// **'Texto copiado.'**
  String get meetingPromoTextCopied;

  /// Placeholder do editor de texto de divulgação.
  ///
  /// In pt, this message translates to:
  /// **'Escreva o texto que acompanha as fotos na divulgação'**
  String get meetingPromoTextHint;

  /// Contador de caracteres do texto de divulgação.
  ///
  /// In pt, this message translates to:
  /// **'{count} de {max} caracteres'**
  String meetingPromoTextCounter(int count, int max);

  /// Erro de texto de divulgação longo demais.
  ///
  /// In pt, this message translates to:
  /// **'O texto passa do limite de {max} caracteres.'**
  String meetingPromoTextTooLong(int max);

  /// Botão para salvar o texto de divulgação.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get meetingPromoTextSave;

  /// Aviso de texto de divulgação salvo.
  ///
  /// In pt, this message translates to:
  /// **'Texto de divulgação salvo.'**
  String get meetingPromoTextSaved;

  /// Erro ao salvar o texto de divulgação.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar o texto de divulgação. Tente novamente.'**
  String get meetingPromoTextSaveFailed;
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
