// ignore_for_file: deprecated_member_use

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Clube de Leitura D\'elas';

  @override
  String get continueAction => 'Continuar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get notProvided => 'Não informado';

  @override
  String get close => 'Fechar';

  @override
  String get loginTitle => 'Faça o seu login';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get emailHint => 'seu@email.com';

  @override
  String get passwordLabel => 'Senha';

  @override
  String get forgotPasswordLink => 'Esqueci minha senha';

  @override
  String get signInWithGoogle => 'Entrar com Google';

  @override
  String get createAccountLink => 'Primeiro acesso? Crie sua conta aqui';

  @override
  String get emailRequiredError => 'Por favor, informe seu e-mail';

  @override
  String get emailInvalidError => 'Informe um e-mail válido';

  @override
  String get passwordRequiredError => 'Por favor, informe sua senha';

  @override
  String get confirmEmailBeforeLoginError =>
      'Por favor, confirme seu e-mail antes de logar.';

  @override
  String get registerTitle => 'Criar Conta';

  @override
  String get confirmPasswordLabel => 'Confirmar Senha';

  @override
  String get passwordMinLengthRequirement => 'Pelo menos 8 caracteres';

  @override
  String get passwordUppercaseRequirement => 'Pelo menos 1 letra maiúscula';

  @override
  String get passwordLowercaseRequirement => 'Pelo menos 1 letra minúscula';

  @override
  String get passwordNumberRequirement => 'Pelo menos 1 número';

  @override
  String get passwordsMatchRequirement => 'Senhas conferem';

  @override
  String get registerButton => 'Cadastrar';

  @override
  String get accountCreatedSuccessMessage =>
      'Conta criada com sucesso! Verifique seu e-mail para confirmar a conta.';

  @override
  String get alreadyHaveAccountLink => 'Já tenho uma conta';

  @override
  String get claimTokenTitle => 'Vincular Perfil';

  @override
  String get claimTokenSuccessMessage => 'Perfil vinculado com sucesso!';

  @override
  String get claimTokenInputHeader => 'Informe o seu Token de Acesso';

  @override
  String get claimTokenInputDescription =>
      'Digite o token fornecido após a aprovação para vincular sua conta.';

  @override
  String get claimTokenFieldLabel => 'Token de acesso';

  @override
  String get claimTokenFieldHint => 'Ex: 1A2B3C4D';

  @override
  String get claimTokenRequiredError => 'Por favor, informe o token de acesso.';

  @override
  String get claimTokenInvalidError =>
      'Token de acesso inválido ou já utilizado. Por favor, verifique o código.';

  @override
  String get genericError =>
      'Ocorreu um erro ao processar sua solicitação. Tente novamente mais tarde.';

  @override
  String get back => 'Voltar';

  @override
  String get logoutTooltip => 'Sair';

  @override
  String get logoutButton => 'Sair da Conta';

  @override
  String get defaultUserName => 'Usuária';

  @override
  String get profileStatusActive => 'Perfil Vinculado & Ativo';

  @override
  String get profileDataSectionTitle => 'Dados do Perfil Cadastrado';

  @override
  String get fullNameLabel => 'Nome Completo';

  @override
  String get phoneLabel => 'Telefone';

  @override
  String get addressLabel => 'Endereço';

  @override
  String get birthdayLabel => 'Data de Nascimento';

  @override
  String get instagramLabel => 'Instagram';

  @override
  String get educationLabel => 'Escolaridade';

  @override
  String get jobPositionLabel => 'Cargo / Profissão';

  @override
  String get authUserIdLabel => 'ID Auth (Supabase User ID)';

  @override
  String get profileLogoutButtonLabel => 'Sair da conta';

  @override
  String get profileTitle => 'Meu Perfil';

  @override
  String get profilePhotoEditButtonLabel => 'Editar foto de perfil';

  @override
  String get editProfilePhotoDialogTitle => 'Editar foto';

  @override
  String get editProfilePhotoChangeButton => 'Trocar foto';

  @override
  String get profilePhotoPreviewSemanticLabel => 'Foto de perfil atual';

  @override
  String get editProfilePhotoUploadFailed =>
      'Não foi possível atualizar a foto. Tente novamente.';

  @override
  String get editProfilePhotoRejected =>
      'Esta foto não pode ser usada como foto de perfil.';

  @override
  String get editProfilePhotoTooLarge =>
      'A foto passa do tamanho máximo permitido.';

  @override
  String get logoutDialogTitle => 'Sair da conta';

  @override
  String get logoutDialogMessage =>
      'Você deseja mesmo sair do aplicativo? Será necessário fazer login novamente para acessar sua conta.';

  @override
  String get logoutDialogCancel => 'Cancelar';

  @override
  String get logoutDialogConfirm => 'Sair';

  @override
  String get ratedBooksTitle => 'Livros avaliados';

  @override
  String get noRatedBooksMessage => 'Nenhum livro avaliado ainda.';

  @override
  String get ratedBooksLoadError =>
      'Não foi possível carregar os livros avaliados.';

  @override
  String get ratedBooksLoading => 'Carregando livros avaliados';

  @override
  String get seeAllBooks => 'Ver todos os livros';

  @override
  String ratedBookTileAuthor(String author) {
    return 'escrito por $author';
  }

  @override
  String ratedBookTileRating(String rating) {
    return 'avaliado com $rating de 5 estrelas';
  }

  @override
  String ratedBookTileComment(String comment) {
    return 'comentário: $comment';
  }
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get appTitle => 'Clube de Leitura D\'elas';

  @override
  String get continueAction => 'Continuar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get notProvided => 'Não informado';

  @override
  String get close => 'Fechar';

  @override
  String get loginTitle => 'Faça o seu login';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get emailHint => 'seu@email.com';

  @override
  String get passwordLabel => 'Senha';

  @override
  String get forgotPasswordLink => 'Esqueci minha senha';

  @override
  String get signInWithGoogle => 'Entrar com Google';

  @override
  String get createAccountLink => 'Primeiro acesso? Crie sua conta aqui';

  @override
  String get emailRequiredError => 'Por favor, informe seu e-mail';

  @override
  String get emailInvalidError => 'Informe um e-mail válido';

  @override
  String get passwordRequiredError => 'Por favor, informe sua senha';

  @override
  String get confirmEmailBeforeLoginError =>
      'Por favor, confirme seu e-mail antes de logar.';

  @override
  String get registerTitle => 'Criar Conta';

  @override
  String get confirmPasswordLabel => 'Confirmar Senha';

  @override
  String get passwordMinLengthRequirement => 'Pelo menos 8 caracteres';

  @override
  String get passwordUppercaseRequirement => 'Pelo menos 1 letra maiúscula';

  @override
  String get passwordLowercaseRequirement => 'Pelo menos 1 letra minúscula';

  @override
  String get passwordNumberRequirement => 'Pelo menos 1 número';

  @override
  String get passwordsMatchRequirement => 'Senhas conferem';

  @override
  String get registerButton => 'Cadastrar';

  @override
  String get accountCreatedSuccessMessage =>
      'Conta criada com sucesso! Verifique seu e-mail para confirmar a conta.';

  @override
  String get alreadyHaveAccountLink => 'Já tenho uma conta';

  @override
  String get claimTokenTitle => 'Vincular Perfil';

  @override
  String get claimTokenSuccessMessage => 'Perfil vinculado com sucesso!';

  @override
  String get claimTokenInputHeader => 'Informe o seu Token de Acesso';

  @override
  String get claimTokenInputDescription =>
      'Digite o token fornecido após a aprovação para vincular sua conta.';

  @override
  String get claimTokenFieldLabel => 'Token de acesso';

  @override
  String get claimTokenFieldHint => 'Ex: 1A2B3C4D';

  @override
  String get claimTokenRequiredError => 'Por favor, informe o token de acesso.';

  @override
  String get claimTokenInvalidError =>
      'Token de acesso inválido ou já utilizado. Por favor, verifique o código.';

  @override
  String get genericError =>
      'Ocorreu um erro ao processar sua solicitação. Tente novamente mais tarde.';

  @override
  String get back => 'Voltar';

  @override
  String get logoutTooltip => 'Sair';

  @override
  String get logoutButton => 'Sair da Conta';

  @override
  String get defaultUserName => 'Usuária';

  @override
  String get profileStatusActive => 'Perfil Vinculado & Ativo';

  @override
  String get profileDataSectionTitle => 'Dados do Perfil Cadastrado';

  @override
  String get fullNameLabel => 'Nome Completo';

  @override
  String get phoneLabel => 'Telefone';

  @override
  String get addressLabel => 'Endereço';

  @override
  String get birthdayLabel => 'Data de Nascimento';

  @override
  String get instagramLabel => 'Instagram';

  @override
  String get educationLabel => 'Escolaridade';

  @override
  String get jobPositionLabel => 'Cargo / Profissão';

  @override
  String get authUserIdLabel => 'ID Auth (Supabase User ID)';

  @override
  String get profileLogoutButtonLabel => 'Sair da conta';

  @override
  String get profileTitle => 'Meu Perfil';

  @override
  String get profilePhotoEditButtonLabel => 'Editar foto de perfil';

  @override
  String get editProfilePhotoDialogTitle => 'Editar foto';

  @override
  String get editProfilePhotoChangeButton => 'Trocar foto';

  @override
  String get profilePhotoPreviewSemanticLabel => 'Foto de perfil atual';

  @override
  String get editProfilePhotoUploadFailed =>
      'Não foi possível atualizar a foto. Tente novamente.';

  @override
  String get editProfilePhotoRejected =>
      'Esta foto não pode ser usada como foto de perfil.';

  @override
  String get editProfilePhotoTooLarge =>
      'A foto passa do tamanho máximo permitido.';

  @override
  String get logoutDialogTitle => 'Sair da conta';

  @override
  String get logoutDialogMessage =>
      'Você deseja mesmo sair do aplicativo? Será necessário fazer login novamente para acessar sua conta.';

  @override
  String get logoutDialogCancel => 'Cancelar';

  @override
  String get logoutDialogConfirm => 'Sair';

  @override
  String get ratedBooksTitle => 'Livros avaliados';

  @override
  String get noRatedBooksMessage => 'Nenhum livro avaliado ainda.';

  @override
  String get ratedBooksLoadError =>
      'Não foi possível carregar os livros avaliados.';

  @override
  String get ratedBooksLoading => 'Carregando livros avaliados';

  @override
  String get seeAllBooks => 'Ver todos os livros';

  @override
  String ratedBookTileAuthor(String author) {
    return 'escrito por $author';
  }

  @override
  String ratedBookTileRating(String rating) {
    return 'avaliado com $rating de 5 estrelas';
  }

  @override
  String ratedBookTileComment(String comment) {
    return 'comentário: $comment';
  }
}
