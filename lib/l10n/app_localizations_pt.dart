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
  String get claimTokenFieldLabel => 'Claim Token';

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
  String get logoutDialogTitle => 'Sair da conta';

  @override
  String get logoutDialogMessage =>
      'Você deseja mesmo sair do aplicativo? Será necessário fazer login novamente para acessar sua conta.';

  @override
  String get logoutDialogCancel => 'Cancelar';

  @override
  String get logoutDialogConfirm => 'Sair';

  @override
  String get meetingEditTitle => 'Editar encontro';

  @override
  String get meetingEditDateLabel => 'Data';

  @override
  String get meetingEditDateHint => 'DD/MM/AAAA';

  @override
  String get meetingEditDateError => 'Informe a data.';

  @override
  String get meetingEditTimeLabel => 'Horário';

  @override
  String get meetingEditTimeHint => 'HH:MM';

  @override
  String get meetingEditTimeError => 'Informe o horário.';

  @override
  String get meetingEditLocationLabel => 'Local';

  @override
  String get meetingEditLocationHint => 'Nome do local';

  @override
  String get meetingEditLocationError => 'Informe o local.';

  @override
  String get meetingEditLocationSelectError => 'Selecione um local da lista.';

  @override
  String get meetingEditLocationSearchError =>
      'Não foi possível buscar locais. Tente novamente.';

  @override
  String get meetingEditDateInvalidError =>
      'Informe uma data válida (DD/MM/AAAA).';

  @override
  String get meetingEditTimeInvalidError =>
      'Informe um horário válido (HH:MM).';

  @override
  String get meetingEditDescriptionLabel => 'Observações';

  @override
  String get meetingEditDescriptionHint => 'Adicione observações (opcional)';

  @override
  String get meetingEditReadOnlySection => 'Informações definidas pelo sorteio';

  @override
  String get meetingEditBookLabel => 'Livro da vez';

  @override
  String get meetingEditHostLabel => 'Anfitriã';

  @override
  String get meetingEditSaveButton => 'Salvar alterações';

  @override
  String meetingCoverSemanticLabel(String title) {
    return 'Foto do $title';
  }

  @override
  String meetingDetailsHost(String name) {
    return 'Anfitriã: $name';
  }

  @override
  String meetingDetailsLocation(String location) {
    return 'Local: $location';
  }

  @override
  String get meetingDetailsLocationUndefined => 'Local: a definir';

  @override
  String get meetingDetailsDescriptionTitle => 'Descrição';

  @override
  String get meetingDetailsOpenMapHint => 'Abrir no Google Maps';

  @override
  String get meetingDetailsMapLaunchError => 'Não foi possível abrir o mapa.';

  @override
  String get meetingPhotosTitle => 'Fotos do encontro';

  @override
  String get meetingPhotosAdd => 'Adicionar fotos';

  @override
  String get meetingPhotosAddMoreSemanticLabel => 'Adicionar mais fotos';

  @override
  String meetingPhotoSemanticLabel(int index) {
    return 'Foto $index do encontro';
  }

  @override
  String meetingPhotosUploading(int current, int total) {
    return 'Enviando $current de $total';
  }

  @override
  String meetingPhotosUploadFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Não foi possível enviar $count fotos.',
      one: 'Não foi possível enviar 1 foto.',
    );
    return '$_temp0';
  }

  @override
  String get meetingPhotosRetryButton => 'Tentar novamente';

  @override
  String get meetingPhotosLoadError =>
      'Não foi possível carregar as fotos do encontro.';

  @override
  String get meetingPhotosEmpty => 'Ainda não há fotos deste encontro.';

  @override
  String get meetingPhotosAccessDenied =>
      'Permita o acesso às fotos nos ajustes do aparelho para adicionar fotos.';

  @override
  String get meetingPhotosPickerFailed =>
      'Não foi possível abrir a galeria. Tente novamente.';

  @override
  String meetingPhotosSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count fotos foram ignoradas: passam de 5 MB ou o formato não é aceito.',
      one: '1 foto foi ignorada: passa de 5 MB ou o formato não é aceito.',
    );
    return '$_temp0';
  }

  @override
  String meetingPhotosLimitReached(int max) {
    return 'Este encontro já tem o máximo de $max fotos.';
  }

  @override
  String meetingPhotosRejected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos foram recusadas e não podem ser enviadas.',
      one: '1 foto foi recusada e não pode ser enviada.',
    );
    return '$_temp0';
  }

  @override
  String get onboardingReviewTitle => 'Verifique os seus dados';

  @override
  String get onboardingNameLabel => 'Nome';

  @override
  String get onboardingEmailLabel => 'E-mail';

  @override
  String get onboardingPhoneLabel => 'Celular';

  @override
  String get onboardingBirthDateLabel => 'Data de nascimento';

  @override
  String get onboardingCityLabel => 'Cidade';

  @override
  String get onboardingCityHint => 'Selecione uma cidade';

  @override
  String get onboardingRegionLabel => 'Região';

  @override
  String get onboardingJobLabel => 'Qual sua profissão?';

  @override
  String get onboardingEducationLabel => 'Nível de escolaridade';

  @override
  String get onboardingEducationHint => 'Selecione um nível';

  @override
  String get onboardingOtherGroupLabel =>
      'Você participa de outro grupo de leitura?';

  @override
  String get onboardingVolunteerLabel =>
      'Teria interesse em se voluntariar como coordenadora de grupo?';

  @override
  String get onboardingBookIndicationLabel =>
      'Qual livro de ficção você indicaria para a leitura coletiva?';

  @override
  String get onboardingBookIndicationHint => 'Digite sua resposta';

  @override
  String get onboardingExpectationsLabel =>
      'O que você espera ao participar do Clube de Leitura D\'Elas?';

  @override
  String get onboardingExpectationsHint => 'Digite sua resposta';

  @override
  String get onboardingBackButton => 'Voltar';

  @override
  String get onboardingContinueButton => 'Continuar';

  @override
  String get onboardingWelcomeTitle => 'Seja Bem-vinda';

  @override
  String get onboardingWelcomeSubtitle =>
      'Sua inscrição foi realizada com sucesso!';

  @override
  String get onboardingWelcomeButton => 'Pronta para o próximo capítulo?';

  @override
  String get selectOptionHint => 'Selecione';

  @override
  String get genreRomance => 'Romance';

  @override
  String get genreFantasy => 'Fantasia';

  @override
  String get genreSuspense => 'Suspense';

  @override
  String get genreNonFiction => 'Não Ficção';

  @override
  String get genreFieldHint => 'Selecione um gênero';

  @override
  String get myGroupsTitle => 'Meus grupos';

  @override
  String get searchGroupPlaceholder => 'Buscar grupo';

  @override
  String get homePendingTasksMessage => 'Você tem tarefas pendentes';

  @override
  String get homePendingTasksAction => 'Tarefas';

  @override
  String get pendingTasksTitle => 'Tarefas pendentes';

  @override
  String get emptyPendingTasks => 'Você não tem tarefas pendentes';

  @override
  String get emptyGroupsTitle => 'Você ainda não participa de nenhum grupo';

  @override
  String get emptyGroupsMessage =>
      'Assim que você entrar em um grupo de leitura, ele aparecerá aqui.';

  @override
  String get emptyGroupsSearch => 'Nenhum grupo encontrado';

  @override
  String groupDetailsNumberLabel(int number) {
    return 'Grupo $number';
  }

  @override
  String get groupNextEventTitle => 'Próximo evento';

  @override
  String get groupNextEventEmpty => 'Nenhum próximo evento agendado';

  @override
  String groupNextEventHost(String name) {
    return 'Anfitriã: $name';
  }

  @override
  String get groupNextEventHistoryLink => 'Histórico de eventos';

  @override
  String get groupNextEventMoreDetailsLink => 'Exibir mais detalhes';

  @override
  String get groupNextEventCurrentBookLabel => 'O livro da vez é:';

  @override
  String groupNextEventBookCoverSemanticLabel(String title) {
    return 'Capa do livro $title';
  }

  @override
  String get groupNextEventBookUndefined => 'Livro ainda não definido';

  @override
  String get groupNextEventNoLocation => 'Sem localização';

  @override
  String get groupParticipantsTitle => 'Participantes';

  @override
  String groupParticipantsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participantes',
      one: '1 participante',
      zero: 'Nenhum participante',
    );
    return '$_temp0';
  }

  @override
  String get groupOpenWhatsAppButton => 'Abrir Whatsapp';

  @override
  String get whatsappLaunchError =>
      'Não foi possível abrir o link do WhatsApp.';

  @override
  String get groupRecommendBookButton => 'Indicar livro';

  @override
  String groupCoverSemanticLabel(String name) {
    return 'Foto do grupo $name';
  }

  @override
  String get groupParticipantsEmpty =>
      'Ainda não há participantes neste grupo.';

  @override
  String get groupParticipantsLoadError =>
      'Não foi possível carregar as participantes.';

  @override
  String get groupParticipantsRetryButton => 'Tentar novamente';

  @override
  String get groupParticipantsLoading => 'Carregando participantes';

  @override
  String get groupNextMeetingLabel => 'Próximo evento';

  @override
  String get groupDeclineMeetingButton => 'Não irei';

  @override
  String get groupConfirmMeetingButton => 'Confirmar presença';

  @override
  String get groupMeetingConfirmedLabel => 'Presença confirmada';

  @override
  String get groupMeetingDeclinedLabel => 'Ausência confirmada';

  @override
  String get groupMeetingRsvpRetryAction => 'Tentar novamente';

  @override
  String get groupEventHistoryTitle => 'Histórico de eventos';

  @override
  String groupEventHistoryHost(String hostName) {
    return 'Anfitriã: $hostName';
  }

  @override
  String get groupEventHistoryDetailsLink => 'Confira mais detalhes';

  @override
  String get groupMeetingMyTasksAction => 'Minhas tarefas';

  @override
  String get groupEventHistoryEmpty =>
      'Este grupo ainda não realizou encontros.';

  @override
  String get meetingDetailsHeader => 'Detalhes do encontro';

  @override
  String meetingDetailsTitle(int number) {
    return 'Encontro $number';
  }

  @override
  String get meetingDetailsTitleFallback => 'Encontro';

  @override
  String meetingDetailsDate(String date) {
    return 'Data: $date';
  }

  @override
  String get meetingDetailsDateUndefined => 'Data: a definir';

  @override
  String meetingDetailsBook(String title) {
    return 'Livro: $title';
  }

  @override
  String get meetingPresenceEmptyTitle => 'Nenhum participante nesta reunião';

  @override
  String get meetingPresenceEmptyDescription =>
      'Quando houver participantes, eles aparecerão aqui para registrar a presença.';

  @override
  String get meetingEditAction => 'Editar encontro';

  @override
  String get meetingPresenceHeader => 'Lista de Presença';

  @override
  String get meetingPresenceConfirmed => 'Presença confirmada';

  @override
  String get meetingPresencePresent => 'Presente';

  @override
  String get meetingPresenceAbsent => 'Ausente';

  @override
  String get invitationConfirmed => 'Confirmou presença';

  @override
  String get invitationNoResponse => 'Sem resposta';

  @override
  String get invitationDeclined => 'Recusou o convite';

  @override
  String get rafflePreparationTitle => 'Realizar sorteio';

  @override
  String get rafflePreparationSubtitle => 'Selecione as participantes';

  @override
  String get raffleTableHeaderName => 'Nome';

  @override
  String get raffleTableHeaderInclude => 'Incluir no sorteio';

  @override
  String get raffleConfirmDialogTitle => 'Confirmar sorteio';

  @override
  String get raffleConfirmDialogMessage =>
      'Você deseja mesmo confirmar o sorteio?';

  @override
  String get raffleConfirmDialogCancel => 'Cancelar';

  @override
  String get raffleSuccessToast => 'Sorteio realizado com sucesso!';

  @override
  String get raffleDrawScreenTitle => 'Realizar Sorteio';

  @override
  String raffleBookDrawTitle(String month) {
    return 'Sorteio do Livro - $month';
  }

  @override
  String get raffleDrawButton => 'SORTEAR';

  @override
  String get raffleDisclaimer =>
      'O sorteio é automático e aleatório.\nA participação é voluntária.';

  @override
  String get raffleResultTitle => 'Resultado do Sorteio';

  @override
  String get raffleDrawnBookLabel => 'Livro sorteado';

  @override
  String get raffleHostLabel => 'Anfitriã';

  @override
  String get raffleHostAnnounceLabel => 'A Anfitriã da vez é';

  @override
  String get raffleFinishButton => 'Concluir';

  @override
  String get raffleDrawAgainButton => 'Sortear novamente';

  @override
  String get raffleErrorMessage => 'Não foi possível concluir o sorteio';

  @override
  String get raffleNoMoreParticipantsToDraw => 'Sem mais pessoas para sortear';

  @override
  String get raffleNoEligibleParticipants =>
      'Não há participantes elegíveis para o sorteio.';

  @override
  String get raffleSavedSuccessToast =>
      'Sorteio registrado com sucesso! Nova anfitriã definida.';

  @override
  String groupMeetingMyTasksProgress(int done, int total) {
    return '$done de $total tarefas concluídas';
  }

  @override
  String get meetingTasksTitle => 'Suas tarefas';

  @override
  String get meetingTasksInvalidMeeting => 'Encontro inválido.';

  @override
  String get meetingTasksRetry => 'Tentar novamente';

  @override
  String get meetingTasksDrawnLabel => 'VOCÊ FOI SORTEADA';

  @override
  String get meetingTasksDrawnFallbackTitle => 'Próximo encontro';

  @override
  String get meetingTasksPublishedLabel => 'TUDO CERTO';

  @override
  String get meetingTasksPublishedTitle => 'Encontro publicado';

  @override
  String get meetingTasksPublishedMessage =>
      'As participantes já foram avisadas.';

  @override
  String meetingTasksPendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tarefas para você',
      one: '1 tarefa para você',
      zero: 'Todas as tarefas concluídas',
    );
    return '$_temp0';
  }

  @override
  String get meetingTasksScheduleTitle => '1. Marcar data e local';

  @override
  String get meetingTasksSchedulePending =>
      'O grupo está esperando para saber quando e onde.';

  @override
  String get meetingTasksScheduleAction => 'Marcar agora';

  @override
  String get meetingTasksRecordTitle => '2. Enviar fotos do encontro';

  @override
  String get meetingTasksRecordLocked =>
      'Disponível depois que o encontro acontecer.';

  @override
  String get meetingTasksRecordPending =>
      'Depois do encontro, compartilhe como foi.';

  @override
  String get meetingTasksRecordDraft =>
      'Você tem um rascunho salvo. Continue de onde parou.';

  @override
  String get meetingTasksRecordDraftTag => 'Rascunho salvo';

  @override
  String get meetingTasksRecordPublished => 'Registro publicado.';

  @override
  String get meetingTasksRecordAction => 'Enviar fotos';

  @override
  String get meetingTasksDoneSemantics => 'Concluída';

  @override
  String get meetingTasksConcludeAction => 'Encerrar encontro';

  @override
  String get meetingTasksConcludeHint =>
      'Este botão ficará ativo quando o encontro iniciar.';

  @override
  String get meetingTasksConcludeDialogTitle => 'Encerrar encontro';

  @override
  String get meetingTasksConcludeDialogMessage =>
      'Você deseja mesmo encerrar o encontro? Para concluir, preencha a lista de presença.';

  @override
  String get meetingTasksConcludeDialogNo => 'Não';

  @override
  String get meetingTasksConcludeDialogYes => 'Sim';

  @override
  String get meetingAttendanceCompleteAction => 'Concluir lista de presença';

  @override
  String get showPasswordTooltip => 'Mostrar senha';

  @override
  String get hidePasswordTooltip => 'Ocultar senha';

  @override
  String get appLogoSemanticLabel => 'Logo do Clube de Leitura D\'Elas';

  @override
  String meetingPhotoViewerTitle(int index, int total) {
    return 'Foto $index de $total';
  }

  @override
  String meetingPhotoOpenSemanticLabel(int index) {
    return 'Abrir foto $index do encontro';
  }

  @override
  String get meetingPhotoDownload => 'Baixar';

  @override
  String get meetingPhotoDownloadFailed =>
      'Não foi possível abrir a foto para baixar.';

  @override
  String get meetingPhotoDelete => 'Remover';

  @override
  String get meetingPhotoDeleteDialogTitle => 'Remover foto';

  @override
  String get meetingPhotoDeleteDialogMessage =>
      'A foto deixa de aparecer no encontro. Deseja remover?';

  @override
  String get meetingPhotoDeleteDialogCancel => 'Cancelar';

  @override
  String get meetingPhotoDeleted => 'Foto removida.';

  @override
  String get meetingPhotoDeleteFailed =>
      'Não foi possível remover a foto. Tente novamente.';

  @override
  String get meetingPromoTextTitle => 'Texto de divulgação';

  @override
  String get meetingPromoTextEmpty => 'Nenhum texto de divulgação anexado.';

  @override
  String get meetingPromoTextAdd => 'Adicionar texto';

  @override
  String get meetingPromoTextEdit => 'Editar';

  @override
  String get meetingPromoTextCopy => 'Copiar';

  @override
  String get meetingPromoTextCopied => 'Texto copiado.';

  @override
  String get meetingPromoTextHint =>
      'Escreva o texto que acompanha as fotos na divulgação';

  @override
  String meetingPromoTextCounter(int count, int max) {
    return '$count de $max caracteres';
  }

  @override
  String meetingPromoTextTooLong(int max) {
    return 'O texto passa do limite de $max caracteres.';
  }

  @override
  String get meetingPromoTextSave => 'Salvar';

  @override
  String get meetingPromoTextSaved => 'Texto de divulgação salvo.';

  @override
  String get meetingPromoTextSaveFailed =>
      'Não foi possível salvar o texto de divulgação. Tente novamente.';
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
  String get claimTokenFieldLabel => 'Claim Token';

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
  String get logoutDialogTitle => 'Sair da conta';

  @override
  String get logoutDialogMessage =>
      'Você deseja mesmo sair do aplicativo? Será necessário fazer login novamente para acessar sua conta.';

  @override
  String get logoutDialogCancel => 'Cancelar';

  @override
  String get logoutDialogConfirm => 'Sair';

  @override
  String get meetingEditTitle => 'Editar encontro';

  @override
  String get meetingEditDateLabel => 'Data';

  @override
  String get meetingEditDateHint => 'DD/MM/AAAA';

  @override
  String get meetingEditDateError => 'Informe a data.';

  @override
  String get meetingEditTimeLabel => 'Horário';

  @override
  String get meetingEditTimeHint => 'HH:MM';

  @override
  String get meetingEditTimeError => 'Informe o horário.';

  @override
  String get meetingEditLocationLabel => 'Local';

  @override
  String get meetingEditLocationHint => 'Busque pelo nome ou endereço';

  @override
  String get meetingEditLocationError => 'Informe o local.';

  @override
  String get meetingEditLocationSelectError => 'Selecione um local da lista.';

  @override
  String get meetingEditLocationSearchError =>
      'Não foi possível buscar locais. Tente novamente.';

  @override
  String get meetingEditDateInvalidError =>
      'Informe uma data válida (DD/MM/AAAA).';

  @override
  String get meetingEditTimeInvalidError =>
      'Informe um horário válido (HH:MM).';

  @override
  String get meetingEditDescriptionLabel => 'Observações';

  @override
  String get meetingEditDescriptionHint => 'Adicione observações (opcional)';

  @override
  String get meetingEditReadOnlySection => 'Informações definidas pelo sorteio';

  @override
  String get meetingEditBookLabel => 'Livro da vez';

  @override
  String get meetingEditHostLabel => 'Anfitriã';

  @override
  String get meetingEditSaveButton => 'Salvar alterações';

  @override
  String meetingCoverSemanticLabel(String title) {
    return 'Foto do $title';
  }

  @override
  String meetingDetailsHost(String name) {
    return 'Anfitriã: $name';
  }

  @override
  String meetingDetailsLocation(String location) {
    return 'Local: $location';
  }

  @override
  String get meetingDetailsLocationUndefined => 'Local: a definir';

  @override
  String get meetingDetailsDescriptionTitle => 'Descrição';

  @override
  String get meetingDetailsOpenMapHint => 'Abrir no Google Maps';

  @override
  String get meetingDetailsMapLaunchError => 'Não foi possível abrir o mapa.';

  @override
  String get meetingPhotosTitle => 'Fotos do encontro';

  @override
  String get meetingPhotosAdd => 'Adicionar fotos';

  @override
  String get meetingPhotosAddMoreSemanticLabel => 'Adicionar mais fotos';

  @override
  String meetingPhotoSemanticLabel(int index) {
    return 'Foto $index do encontro';
  }

  @override
  String meetingPhotosUploading(int current, int total) {
    return 'Enviando $current de $total';
  }

  @override
  String meetingPhotosUploadFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Não foi possível enviar $count fotos.',
      one: 'Não foi possível enviar 1 foto.',
    );
    return '$_temp0';
  }

  @override
  String get meetingPhotosRetryButton => 'Tentar novamente';

  @override
  String get meetingPhotosLoadError =>
      'Não foi possível carregar as fotos do encontro.';

  @override
  String get meetingPhotosEmpty => 'Ainda não há fotos deste encontro.';

  @override
  String get meetingPhotosAccessDenied =>
      'Permita o acesso às fotos nos ajustes do aparelho para adicionar fotos.';

  @override
  String get meetingPhotosPickerFailed =>
      'Não foi possível abrir a galeria. Tente novamente.';

  @override
  String meetingPhotosSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count fotos foram ignoradas: passam de 5 MB ou o formato não é aceito.',
      one: '1 foto foi ignorada: passa de 5 MB ou o formato não é aceito.',
    );
    return '$_temp0';
  }

  @override
  String meetingPhotosLimitReached(int max) {
    return 'Este encontro já tem o máximo de $max fotos.';
  }

  @override
  String meetingPhotosRejected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos foram recusadas e não podem ser enviadas.',
      one: '1 foto foi recusada e não pode ser enviada.',
    );
    return '$_temp0';
  }

  @override
  String get onboardingReviewTitle => 'Verifique os seus dados';

  @override
  String get onboardingNameLabel => 'Nome';

  @override
  String get onboardingEmailLabel => 'E-mail';

  @override
  String get onboardingPhoneLabel => 'Celular';

  @override
  String get onboardingBirthDateLabel => 'Data de nascimento';

  @override
  String get onboardingCityLabel => 'Cidade';

  @override
  String get onboardingCityHint => 'Selecione uma cidade';

  @override
  String get onboardingRegionLabel => 'Região';

  @override
  String get onboardingJobLabel => 'Qual sua profissão?';

  @override
  String get onboardingEducationLabel => 'Nível de escolaridade';

  @override
  String get onboardingEducationHint => 'Selecione um nível';

  @override
  String get onboardingOtherGroupLabel =>
      'Você participa de outro grupo de leitura?';

  @override
  String get onboardingVolunteerLabel =>
      'Teria interesse em se voluntariar como coordenadora de grupo?';

  @override
  String get onboardingBookIndicationLabel =>
      'Qual livro de ficção você indicaria para a leitura coletiva?';

  @override
  String get onboardingBookIndicationHint => 'Digite sua resposta';

  @override
  String get onboardingExpectationsLabel =>
      'O que você espera ao participar do Clube de Leitura D\'Elas?';

  @override
  String get onboardingExpectationsHint => 'Digite sua resposta';

  @override
  String get onboardingBackButton => 'Voltar';

  @override
  String get onboardingContinueButton => 'Continuar';

  @override
  String get onboardingWelcomeTitle => 'Seja Bem-vinda';

  @override
  String get onboardingWelcomeSubtitle =>
      'Sua inscrição foi realizada com sucesso!';

  @override
  String get onboardingWelcomeButton => 'Pronta para o próximo capítulo?';

  @override
  String get selectOptionHint => 'Selecione';

  @override
  String get myGroupsTitle => 'Meus grupos';

  @override
  String get searchGroupPlaceholder => 'Buscar grupo';

  @override
  String get homePendingTasksMessage => 'Você tem tarefas pendentes';

  @override
  String get homePendingTasksAction => 'Tarefas';

  @override
  String get pendingTasksTitle => 'Tarefas pendentes';

  @override
  String get emptyPendingTasks => 'Você não tem tarefas pendentes';

  @override
  String get emptyGroupsTitle => 'Você ainda não participa de nenhum grupo';

  @override
  String get emptyGroupsMessage =>
      'Assim que você entrar em um grupo de leitura, ele aparecerá aqui.';

  @override
  String get groupNextEventTitle => 'Próximo evento';

  @override
  String get groupNextEventEmpty => 'Nenhum próximo evento agendado';

  @override
  String groupNextEventHost(String name) {
    return 'Anfitriã: $name';
  }

  @override
  String get groupNextEventHistoryLink => 'Histórico de eventos';

  @override
  String get groupNextEventMoreDetailsLink => 'Exibir mais detalhes';

  @override
  String get groupNextEventCurrentBookLabel => 'O livro da vez é:';

  @override
  String groupNextEventBookCoverSemanticLabel(String title) {
    return 'Capa do livro $title';
  }

  @override
  String get groupNextEventBookUndefined => 'Livro ainda não definido';

  @override
  String get groupParticipantsTitle => 'Participantes';

  @override
  String groupParticipantsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participantes',
      one: '1 participante',
      zero: 'Nenhum participante',
    );
    return '$_temp0';
  }

  @override
  String get groupOpenWhatsAppButton => 'Abrir Whatsapp';

  @override
  String get whatsappLaunchError =>
      'Não foi possível abrir o link do WhatsApp.';

  @override
  String get groupRecommendBookButton => 'Indicar livro';

  @override
  String groupCoverSemanticLabel(String name) {
    return 'Foto do grupo $name';
  }

  @override
  String get groupParticipantsEmpty =>
      'Ainda não há participantes neste grupo.';

  @override
  String get groupParticipantsLoadError =>
      'Não foi possível carregar as participantes.';

  @override
  String get groupParticipantsRetryButton => 'Tentar novamente';

  @override
  String get groupParticipantsLoading => 'Carregando participantes';

  @override
  String get groupEventHistoryTitle => 'Histórico de eventos';

  @override
  String groupEventHistoryHost(String hostName) {
    return 'Anfitriã: $hostName';
  }

  @override
  String get groupEventHistoryDetailsLink => 'Confira mais detalhes';

  @override
  String get groupMeetingMyTasksAction => 'Minhas tarefas';

  @override
  String get groupEventHistoryEmpty =>
      'Este grupo ainda não realizou encontros.';

  @override
  String get meetingDetailsHeader => 'Detalhes do encontro';

  @override
  String meetingDetailsTitle(int number) {
    return 'Encontro $number';
  }

  @override
  String get meetingDetailsTitleFallback => 'Encontro';

  @override
  String meetingDetailsDate(String date) {
    return 'Data: $date';
  }

  @override
  String get meetingDetailsDateUndefined => 'Data: a definir';

  @override
  String meetingDetailsBook(String title) {
    return 'Livro: $title';
  }

  @override
  String get meetingPresenceEmptyTitle => 'Nenhum participante nesta reunião';

  @override
  String get meetingPresenceEmptyDescription =>
      'Quando houver participantes, eles aparecerão aqui para registrar a presença.';

  @override
  String get meetingEditAction => 'Editar encontro';

  @override
  String get meetingPresenceHeader => 'Lista de Presença';

  @override
  String get meetingPresenceConfirmed => 'Presença confirmada';

  @override
  String get meetingPresencePresent => 'Presente';

  @override
  String get meetingPresenceAbsent => 'Ausente';

  @override
  String get invitationConfirmed => 'Confirmou presença';

  @override
  String get invitationNoResponse => 'Sem resposta';

  @override
  String get invitationDeclined => 'Recusou o convite';

  @override
  String get rafflePreparationTitle => 'Realizar sorteio';

  @override
  String get rafflePreparationSubtitle => 'Selecione as participantes';

  @override
  String get raffleTableHeaderName => 'Nome';

  @override
  String get raffleTableHeaderInclude => 'Incluir no sorteio';

  @override
  String get raffleConfirmDialogTitle => 'Confirmar sorteio';

  @override
  String get raffleConfirmDialogMessage =>
      'Você deseja mesmo confirmar o sorteio?';

  @override
  String get raffleConfirmDialogCancel => 'Cancelar';

  @override
  String get raffleSuccessToast => 'Sorteio realizado com sucesso!';

  @override
  String get raffleDrawScreenTitle => 'Realizar Sorteio';

  @override
  String raffleBookDrawTitle(String month) {
    return 'Sorteio do Livro - $month';
  }

  @override
  String get raffleDrawButton => 'SORTEAR';

  @override
  String get raffleDisclaimer =>
      'O sorteio é automático e aleatório.\nA participação é voluntária.';

  @override
  String get raffleResultTitle => 'Resultado do Sorteio';

  @override
  String get raffleDrawnBookLabel => 'Livro sorteado';

  @override
  String get raffleHostLabel => 'Anfitriã';

  @override
  String get raffleHostAnnounceLabel => 'A Anfitriã da vez é';

  @override
  String get raffleFinishButton => 'Concluir';

  @override
  String get raffleDrawAgainButton => 'Sortear novamente';

  @override
  String get raffleErrorMessage => 'Não foi possível concluir o sorteio';

  @override
  String get raffleNoMoreParticipantsToDraw => 'Sem mais pessoas para sortear';

  @override
  String get raffleNoEligibleParticipants =>
      'Não há participantes elegíveis para o sorteio.';

  @override
  String get raffleSavedSuccessToast =>
      'Sorteio registrado com sucesso! Nova anfitriã definida.';
}
