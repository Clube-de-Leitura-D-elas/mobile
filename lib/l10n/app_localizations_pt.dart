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
  String get welcomeMessage => 'Bem-vinda!';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get delete => 'Excluir';

  @override
  String get edit => 'Editar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get back => 'Voltar';

  @override
  String get close => 'Fechar';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get search => 'Buscar';

  @override
  String get continueAction => 'Continuar';

  @override
  String get errorGeneric => 'Ocorreu um erro inesperado. Tente novamente.';

  @override
  String get errorNetwork =>
      'Sem conexão com a internet. Verifique sua rede e tente novamente.';

  @override
  String get errorTimeout =>
      'O tempo de resposta da requisição esgotou. Tente novamente.';

  @override
  String get errorUnauthorized =>
      'Sessão expirada ou não autorizada. Por favor, faça login novamente.';

  @override
  String get errorForbidden =>
      'Você não tem permissão para realizar esta ação.';

  @override
  String get errorNotFound => 'O recurso solicitado não foi encontrado.';

  @override
  String get errorBadRequest =>
      'Requisição inválida. Verifique os dados e tente novamente.';

  @override
  String get errorInternalServer =>
      'Ocorreu uma falha nos nossos servidores. Tente novamente mais tarde.';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get appTitle => 'Clube de Leitura D\'elas';

  @override
  String get welcomeMessage => 'Bem-vinda!';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get delete => 'Excluir';

  @override
  String get edit => 'Editar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get back => 'Voltar';

  @override
  String get close => 'Fechar';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get search => 'Buscar';

  @override
  String get continueAction => 'Continuar';

  @override
  String get errorGeneric => 'Ocorreu um erro inesperado. Tente novamente.';

  @override
  String get errorNetwork =>
      'Sem conexão com a internet. Verifique sua rede e tente novamente.';

  @override
  String get errorTimeout =>
      'O tempo de resposta da requisição esgotou. Tente novamente.';

  @override
  String get errorUnauthorized =>
      'Sessão expirada ou não autorizada. Por favor, faça login novamente.';

  @override
  String get errorForbidden =>
      'Você não tem permissão para realizar esta ação.';

  @override
  String get errorNotFound => 'O recurso solicitado não foi encontrado.';

  @override
  String get errorBadRequest =>
      'Requisição inválida. Verifique os dados e tente novamente.';

  @override
  String get errorInternalServer =>
      'Ocorreu uma falha nos nossos servidores. Tente novamente mais tarde.';
}
