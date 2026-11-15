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
  String get meetingPhotoCaptionTitle => 'Legenda da foto';

  @override
  String get meetingPhotoCaptionHint => 'Escreva uma legenda para esta foto';

  @override
  String meetingPhotoCaptionCounter(int current, int max) {
    return '$current de $max';
  }

  @override
  String meetingPhotoCaptionTooLong(int max) {
    return 'A legenda deve ter no máximo $max caracteres.';
  }

  @override
  String get meetingPhotoCaptionSave => 'Salvar legenda';

  @override
  String get meetingPhotoCaptionSkip => 'Sem legenda';

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
  String get onboardingBirthDateHint => 'DD/MM/AAAA';

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
  String get clearSearchTooltip => 'Limpar busca';

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
  String get groupNextEventTimeUndefined => '--:--';

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
  String get groupParticipantCoordinatorTag => 'Coordenadora';

  @override
  String get groupParticipantHostTag => 'Anfitriã';

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
  String meetingDetailsTime(String time) {
    return 'Horário: $time';
  }

  @override
  String get meetingDetailsTimeUndefined => 'Horário: a definir';

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
  String get raffleTableHeaderName => 'Participante';

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
  String get raffleErrorMessage =>
      'Não foi possível concluir o sorteio. Tente novamente.';

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
  String get meetingTasksScheduleEditAction => 'Editar data e local';

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
  String get meetingPhotoPrevious => 'Foto anterior';

  @override
  String get meetingPhotoNext => 'Próxima foto';

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

  @override
  String starRatingSemanticLabel(String rating, int maxStars) {
    return '$rating de $maxStars estrelas';
  }

  @override
  String starRatingInputStarLabel(int starValue, int maxStars) {
    return '$starValue de $maxStars estrelas';
  }

  @override
  String get readingStatusRead => 'Já lido';

  @override
  String get readingStatusWantToRead => 'Quero ler';

  @override
  String get readingStatusMarkAsRead => 'Marcar como lido';

  @override
  String get bookGroupAlreadySuggested => 'já indicado';

  @override
  String bookDetailWrittenBy(String author) {
    return 'Escrito por $author';
  }

  @override
  String get bookDetailNoRatings => 'Ainda sem avaliações';

  @override
  String get notificationsTitle => 'Notificações';

  @override
  String notificationsUnreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count não lidas',
      one: '1 não lida',
    );
    return '$_temp0';
  }

  @override
  String get notificationsBadgeOverflow => '99+';

  @override
  String get notificationsEmpty => 'Nenhuma notificação por aqui';

  @override
  String get notificationsLoadError =>
      'Não foi possível carregar suas notificações.';

  @override
  String get notificationsLoadMoreError =>
      'Não foi possível carregar mais notificações.';

  @override
  String get notificationsRetry => 'Tentar novamente';

  @override
  String get notificationsLoading => 'Carregando notificações';

  @override
  String get notificationsLoadingMore => 'Carregando mais notificações';

  @override
  String notificationTileUnreadSemantic(String title, String message) {
    return 'Não lida: $title. $message';
  }

  @override
  String notificationTileReadSemantic(String title, String message) {
    return '$title. $message';
  }

  @override
  String get notificationDateNow => 'agora';

  @override
  String notificationDateMinutes(int count) {
    return 'há $count min';
  }

  @override
  String notificationDateHours(int count) {
    return 'há $count h';
  }

  @override
  String notificationDateDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count dias',
      one: 'ontem',
    );
    return '$_temp0';
  }

  @override
  String get bookDetailScreenTitle => 'Detalhes do livro';

  @override
  String get bookDetailRateButton => 'Avaliar';

  @override
  String get bookDetailEditReviewButton => 'Editar avaliação';

  @override
  String get bookReviewDialogTitle => 'Avaliar livro';

  @override
  String get bookReviewRatingLabel => 'Sua nota';

  @override
  String get bookReviewCommentLabel => 'Adicione seu comentário (opcional)';

  @override
  String get bookReviewCommentHint => 'Digite sua resposta';

  @override
  String get bookReviewCancel => 'Cancelar';

  @override
  String get bookReviewSubmit => 'Concluir';

  @override
  String get bookReviewSuccess => 'Avaliação salva com sucesso.';

  @override
  String get bookReviewError => 'Não foi possível salvar sua avaliação.';

  @override
  String get bookDetailRecommendButton => 'Indicar';

  @override
  String get bookDetailSynopsisTitle => 'Sinopse';

  @override
  String get bookDetailReviewsTitle => 'Comentários';

  @override
  String get bookDetailNoReviews => 'Ainda não há comentários';

  @override
  String get bookDetailNoSynopsis => 'Este livro ainda não tem sinopse.';

  @override
  String get bookDetailLoading => 'Carregando livro';

  @override
  String get bookDetailLoadError => 'Não foi possível carregar o livro.';

  @override
  String get bookDetailNotFound => 'Livro não encontrado.';

  @override
  String get bookDetailLoadingMoreReviews => 'Carregando mais comentários';

  @override
  String get bookDetailLoadMoreReviewsError =>
      'Não foi possível carregar mais comentários.';

  @override
  String get bookSearchTitle => 'Busca';

  @override
  String get bookSearchHint => 'Buscar livro';

  @override
  String get bookSearchPopularTitle => 'Populares esse mês';

  @override
  String get bookSearchEmpty => 'Nenhum livro encontrado';

  @override
  String get bookSearchLoadError =>
      'Não foi possível carregar os livros. Tente novamente.';

  @override
  String get bookSearchLoading => 'Carregando livros';

  @override
  String get bookReadingStatusError =>
      'Não foi possível atualizar o status de leitura.';

  @override
  String get errorRetryButton => 'Tentar novamente';

  @override
  String get errorNoConnection =>
      'Sem conexão com a internet. Verifique sua conexão e tente novamente.';

  @override
  String get errorSessionExpired =>
      'Sua sessão expirou. Saia do app e entre de novo na sua conta.';

  @override
  String get authInvalidCredentialsError =>
      'E-mail ou senha incorretos. Confira os dados e tente novamente.';

  @override
  String get authEmailAlreadyRegisteredError =>
      'Este e-mail já tem uma conta. Volte e entre com ele, ou use outro e-mail.';

  @override
  String get authWeakPasswordError =>
      'Essa senha não é segura. Escolha outra senha e tente novamente.';

  @override
  String get authTooManyAttemptsError =>
      'Muitas tentativas seguidas. Aguarde alguns minutos e tente novamente.';

  @override
  String get authGoogleUnavailableError =>
      'Não foi possível entrar com o Google. Tente novamente ou entre com e-mail e senha.';

  @override
  String get authLoginFailedError =>
      'Não foi possível entrar. Tente novamente em alguns minutos.';

  @override
  String get authSignUpFailedError =>
      'Não foi possível criar sua conta. Tente novamente em alguns minutos.';

  @override
  String get claimTokenFailedError =>
      'Não foi possível validar o token agora. Tente novamente em alguns minutos.';

  @override
  String sessionProfileLoadError(String reason) {
    return 'Não foi possível carregar sua conta. $reason';
  }

  @override
  String get onboardingProfileLoadError =>
      'Não foi possível carregar seus dados.';

  @override
  String get onboardingProfileSaveError =>
      'Não foi possível salvar seus dados. Tente novamente.';

  @override
  String get raffleAlreadyRecordedError =>
      'O sorteio deste encontro já foi feito.';

  @override
  String get raffleParticipantsChangedError =>
      'A lista de participantes mudou.';

  @override
  String get appStartupError =>
      'Não foi possível abrir o aplicativo. Feche e abra de novo; se continuar, atualize o app.';

  @override
  String get routeNotFoundMessage => 'Página não encontrada.';

  @override
  String get routeNotFoundHomeButton => 'Ir para o início';

  @override
  String get errorForbidden => 'Você não tem permissão para fazer isso.';

  @override
  String get raffleMeetingNotEndedError =>
      'O sorteio só fica disponível depois que o encontro é encerrado.';

  @override
  String get raffleBookAlreadyDrawnError =>
      'O livro sorteado já saiu em outro sorteio deste grupo.';

  @override
  String get raffleBookSuggestionUnavailableError =>
      'A indicação de livro de uma participante não está mais disponível.';

  @override
  String get raffleRetryShowResultHint =>
      'Toque em Tentar novamente para ver o resultado.';

  @override
  String get raffleRetryRefreshListHint =>
      'Toque em Tentar novamente para atualizar a lista.';

  @override
  String get raffleListRefreshedHint =>
      'Atualizamos a lista: confira as participantes e confirme de novo.';

  @override
  String calendarMonthName(DateTime month) {
    final intl.DateFormat monthDateFormat = intl.DateFormat.LLLL(localeName);
    final String monthString = monthDateFormat.format(month);

    return '$monthString';
  }

  @override
  String calendarMonthSemantic(DateTime month) {
    final intl.DateFormat monthDateFormat = intl.DateFormat.yMMMM(localeName);
    final String monthString = monthDateFormat.format(month);

    return '$monthString';
  }

  @override
  String get calendarPreviousMonth => 'Mês anterior';

  @override
  String get calendarNextMonth => 'Próximo mês';

  @override
  String calendarWeekdayShort(String weekday) {
    String _temp0 = intl.Intl.selectLogic(weekday, {
      'sunday': 'Dom',
      'monday': 'Seg',
      'tuesday': 'Ter',
      'wednesday': 'Qua',
      'thursday': 'Qui',
      'friday': 'Sex',
      'saturday': 'Sáb',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String calendarDaySemantic(DateTime day, int count) {
    final intl.DateFormat dayDateFormat = intl.DateFormat.MMMMd(localeName);
    final String dayString = dayDateFormat.format(day);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count encontros',
      one: '1 encontro',
      zero: 'sem encontros',
    );
    return '$dayString, $_temp0';
  }

  @override
  String get calendarToday => 'Hoje';

  @override
  String get calendarFilterAll => 'Todos';

  @override
  String calendarFilterUpcoming(int count) {
    return 'Próximos eventos ($count)';
  }

  @override
  String get calendarFilterPast => 'Eventos passados';

  @override
  String calendarSelectedDayTitle(DateTime day) {
    final intl.DateFormat dayDateFormat = intl.DateFormat.MMMMEEEEd(localeName);
    final String dayString = dayDateFormat.format(day);

    return '$dayString';
  }

  @override
  String get calendarClearSelectedDay => 'Limpar dia selecionado';

  @override
  String calendarMeetingTitle(int number) {
    return 'Encontro Grupo $number';
  }

  @override
  String calendarMeetingTitleWithDate(DateTime date, int number) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString - Encontro Grupo $number';
  }

  @override
  String calendarMeetingTime(DateTime time) {
    final intl.DateFormat timeDateFormat = intl.DateFormat.Hm(localeName);
    final String timeString = timeDateFormat.format(time);

    return '$timeString';
  }

  @override
  String calendarParticipantsCount(int count) {
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
  String calendarMeetingPlaceWithCity(String place, String city) {
    return '$place, $city';
  }

  @override
  String calendarMeetingHost(String name) {
    return '$name (Anfitriã)';
  }

  @override
  String get calendarLoading => 'Carregando encontros';

  @override
  String get calendarLoadError => 'Não foi possível carregar o calendário.';

  @override
  String get calendarEmptyMonth => 'Nenhum encontro neste mês.';

  @override
  String get calendarEmptyUpcoming => 'Nenhum próximo encontro neste mês.';

  @override
  String get calendarEmptyPast => 'Nenhum encontro passado neste mês.';

  @override
  String get calendarEmptyDay => 'Nenhum encontro neste dia.';

  @override
  String calendarMonthTitle(String month, int year) {
    return '$month $year';
  }

  @override
  String get calendarMeetingDraftTag => 'Rascunho';

  @override
  String get publicGroupTitle => 'Detalhes do grupo';

  @override
  String get publicGroupLoading => 'Carregando grupo';

  @override
  String get publicGroupLoadError => 'Não foi possível carregar o grupo.';

  @override
  String get publicGroupUnavailable => 'Este grupo não está disponível.';

  @override
  String get publicGroupRequestJoin => 'Solicitar entrada';

  @override
  String get publicGroupRequestAgain => 'Pedir novamente';

  @override
  String get publicGroupStatusRequested => 'Aguardando aprovação';

  @override
  String get publicGroupStatusRejected => 'Solicitação recusada';

  @override
  String get publicGroupStatusPending => 'Aguardando criação de conta';

  @override
  String get publicGroupStatusMember => 'Você já faz parte deste grupo';

  @override
  String get publicGroupOpenMemberDetails => 'Ver grupo';

  @override
  String get publicGroupJoinDialogTitle => 'Solicitar entrada?';

  @override
  String publicGroupJoinDialogMessage(int number) {
    return 'A coordenação do Grupo $number vai analisar o seu pedido.';
  }

  @override
  String get publicGroupJoinDialogCancel => 'Cancelar';

  @override
  String get publicGroupJoinDialogConfirm => 'Solicitar';

  @override
  String get publicGroupJoinSuccess =>
      'Pedido enviado! Agora é só aguardar a aprovação.';

  @override
  String get publicGroupJoinAlreadyRequested =>
      'Você já pediu entrada ou já faz parte deste grupo.';

  @override
  String get publicGroupJoinNoCoordinator =>
      'Este grupo ainda não aceita pedidos de entrada.';

  @override
  String get publicGroupJoinError =>
      'Não foi possível enviar o pedido. Tente novamente.';

  @override
  String get searchTabBooks => 'Livros';

  @override
  String get searchTabGroups => 'Grupos';

  @override
  String get groupSearchTitle => 'Encontre seu grupo ideal';

  @override
  String get groupSearchHint => 'Buscar grupo';

  @override
  String get groupSearchFiltersButton => 'Filtros';

  @override
  String get groupSearchFiltersActive => 'Filtros aplicados';

  @override
  String get cityFilterLabel => 'Cidade';

  @override
  String get cityFilterAll => 'Todas as cidades';

  @override
  String cityFilterOption(String name, String uf) {
    return '$name, $uf';
  }

  @override
  String get groupSearchFilterMin => 'Mínimo de participantes';

  @override
  String get groupSearchFilterMinHint => 'Ex.: 10';

  @override
  String get groupSearchFilterMax => 'Máximo de participantes';

  @override
  String get groupSearchFilterMaxHint => 'Ex.: 20';

  @override
  String get groupSearchFilterRangeError =>
      'O mínimo não pode ser maior que o máximo.';

  @override
  String get groupSearchFiltersApply => 'Aplicar filtros';

  @override
  String get groupSearchFiltersClear => 'Limpar filtros';

  @override
  String get groupSearchLoading => 'Carregando grupos';

  @override
  String get groupSearchLoadingMore => 'Carregando mais grupos';

  @override
  String get groupSearchLoadError => 'Não foi possível carregar os grupos.';

  @override
  String get groupSearchLoadMoreError =>
      'Não foi possível carregar mais grupos.';

  @override
  String get groupSearchEmpty => 'Ainda não há grupos ativos.';

  @override
  String get groupSearchEmptyFiltered =>
      'Nenhum grupo encontrado. Tente outra busca ou mude os filtros.';

  @override
  String get groupSearchEnd => 'Você chegou ao fim da lista.';

  @override
  String get groupSearchSeeDetails => 'Ver detalhes';

  @override
  String groupSearchSeeDetailsSemantic(int number) {
    return 'Ver detalhes do Grupo $number';
  }

  @override
  String groupJoinRequestsAccess(int count) {
    return 'Pedidos de entrada ($count)';
  }

  @override
  String get groupJoinRequestsTitle => 'Pedidos de entrada';

  @override
  String get groupJoinRequestsLoading => 'Carregando pedidos de entrada';

  @override
  String get groupJoinRequestsEmpty => 'Nenhum pedido de entrada';

  @override
  String get groupJoinRequestsLoadError =>
      'Não foi possível carregar os pedidos de entrada.';

  @override
  String get groupJoinRequestsNotCoordinator =>
      'Só a coordenação do grupo pode ver os pedidos de entrada.';

  @override
  String get groupJoinRequestsGroupUnavailable =>
      'Este grupo não está disponível.';

  @override
  String groupJoinRequestsRequestedAt(DateTime date, DateTime time) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);
    final intl.DateFormat timeDateFormat = intl.DateFormat.Hm(localeName);
    final String timeString = timeDateFormat.format(time);

    return 'Pedido em $dateString às $timeString';
  }

  @override
  String get groupJoinRequestsApprove => 'Aceitar';

  @override
  String get groupJoinRequestsReject => 'Recusar';

  @override
  String get groupJoinRequestsApproveDialogTitle => 'Aceitar pedido?';

  @override
  String groupJoinRequestsApproveDialogMessage(String name) {
    return '$name vai passar a fazer parte do grupo.';
  }

  @override
  String get groupJoinRequestsRejectDialogTitle => 'Recusar pedido?';

  @override
  String groupJoinRequestsRejectDialogMessage(String name) {
    return '$name não vai entrar no grupo agora, mas poderá pedir de novo.';
  }

  @override
  String get groupJoinRequestsDialogCancel => 'Cancelar';

  @override
  String get groupJoinRequestsApproved =>
      'Pedido aceito! A leitora já faz parte do grupo.';

  @override
  String get groupJoinRequestsRejected => 'Pedido recusado.';

  @override
  String get groupJoinRequestsAlreadyReviewed =>
      'Este pedido já foi respondido.';

  @override
  String get groupJoinRequestsNotFound =>
      'Este pedido não está mais disponível.';

  @override
  String get groupJoinRequestsNoLongerValid =>
      'Este pedido não pode mais ser aceito: o grupo ou a conta da leitora foi desativado.';

  @override
  String get groupJoinRequestsReviewError =>
      'Não foi possível responder ao pedido. Tente novamente.';

  @override
  String groupJoinRequestsApproveSemantics(String name) {
    return 'Aceitar pedido de $name';
  }

  @override
  String groupJoinRequestsRejectSemantics(String name) {
    return 'Recusar pedido de $name';
  }

  @override
  String profileBooksReadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count livros lidos',
      one: '1 livro lido',
      zero: '0 livros lidos',
    );
    return '$_temp0';
  }

  @override
  String profileGroupsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count grupos',
      one: '1 grupo',
      zero: '0 grupos',
    );
    return '$_temp0';
  }

  @override
  String get profileMyGroupsTitle => 'Meus grupos';

  @override
  String profileGroupLabel(int number) {
    return 'Grupo $number';
  }

  @override
  String get profileMoreGroupsButtonLabel => 'Ver mais grupos';

  @override
  String get profileNoGroups => 'Você ainda não participa de nenhum grupo.';

  @override
  String get profileReviewedBooksTitle => 'Livros avaliados';

  @override
  String get profileNoReviewedBooks => 'Você ainda não avaliou nenhum livro.';

  @override
  String get profileSeeAllBooks => 'Ver todos os livros';

  @override
  String get profileSummaryLoading => 'Carregando seus grupos e livros';

  @override
  String get profileSummaryLoadError =>
      'Não foi possível carregar seus grupos e livros.';

  @override
  String get meetingPresenceEmptyConfirmTitle => 'Ninguém compareceu?';

  @override
  String get meetingPresenceEmptyConfirmMessage =>
      'Nenhuma participante está marcada. Ao confirmar, todas ficam com falta e a lista não pode ser alterada depois.';

  @override
  String get meetingPresenceEmptyConfirmCancel => 'Voltar';

  @override
  String get meetingPresenceEmptyConfirmConfirm => 'Confirmar mesmo assim';

  @override
  String profileClubTimeMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meses no clube',
      one: '1 mês no clube',
      zero: 'Chegou ao clube este mês',
    );
    return '$_temp0';
  }

  @override
  String profileClubTimeYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count anos no clube',
      one: '1 ano no clube',
    );
    return '$_temp0';
  }

  @override
  String meetingGuestRequestsAccess(int count) {
    return 'Pedidos de participação ($count)';
  }

  @override
  String get meetingGuestRequestsTitle => 'Pedidos de participação';

  @override
  String get meetingGuestRequestsLoading =>
      'Carregando pedidos de participação';

  @override
  String get meetingGuestRequestsEmpty => 'Nenhum pedido de participação';

  @override
  String get meetingGuestRequestsLoadError =>
      'Não foi possível carregar os pedidos de participação.';

  @override
  String get meetingGuestRequestsNotReviewer =>
      'Só a anfitriã do encontro ou a coordenação do grupo pode ver os pedidos de participação.';

  @override
  String get meetingGuestRequestsMeetingUnavailable =>
      'Este encontro não está disponível.';

  @override
  String meetingGuestRequestsRequestedAt(DateTime date, DateTime time) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);
    final intl.DateFormat timeDateFormat = intl.DateFormat.Hm(localeName);
    final String timeString = timeDateFormat.format(time);

    return 'Pedido em $dateString às $timeString';
  }

  @override
  String get meetingGuestRequestsApprove => 'Aceitar';

  @override
  String get meetingGuestRequestsReject => 'Recusar';

  @override
  String get meetingGuestRequestsApproveDialogTitle => 'Aceitar pedido?';

  @override
  String meetingGuestRequestsApproveDialogMessage(String name) {
    return '$name vai participar deste encontro como convidada.';
  }

  @override
  String get meetingGuestRequestsRejectDialogTitle => 'Recusar pedido?';

  @override
  String meetingGuestRequestsRejectDialogMessage(String name) {
    return '$name não vai participar deste encontro, mas poderá pedir de novo.';
  }

  @override
  String get meetingGuestRequestsDialogCancel => 'Cancelar';

  @override
  String get meetingGuestRequestsApproved =>
      'Pedido aceito! A leitora foi confirmada no encontro.';

  @override
  String get meetingGuestRequestsRejected => 'Pedido recusado.';

  @override
  String get meetingGuestRequestsAlreadyReviewed =>
      'Este pedido já foi respondido.';

  @override
  String get meetingGuestRequestsNotFound =>
      'Este pedido não está mais disponível.';

  @override
  String get meetingGuestRequestsNoLongerValid =>
      'Este pedido não pode mais ser aceito: o encontro foi encerrado, a conta da leitora foi desativada ou ela já faz parte do grupo.';

  @override
  String get meetingGuestRequestsReviewError =>
      'Não foi possível responder ao pedido. Tente novamente.';

  @override
  String meetingGuestRequestsApproveSemantics(String name) {
    return 'Aceitar pedido de participação de $name';
  }

  @override
  String meetingGuestRequestsRejectSemantics(String name) {
    return 'Recusar pedido de participação de $name';
  }

  @override
  String get meetingAttendanceGuestTag => 'Convidada';

  @override
  String get calendarGuestRequest => 'Solicitar participação';

  @override
  String get calendarGuestRequestAgain => 'Pedir novamente';

  @override
  String get calendarGuestStatusRequested => 'Aguardando aprovação';

  @override
  String get calendarGuestStatusAccepted => 'Participação confirmada';

  @override
  String get calendarGuestStatusRejected => 'Pedido recusado';

  @override
  String get calendarGuestDialogTitle => 'Solicitar participação?';

  @override
  String calendarGuestDialogMessage(int number) {
    return 'A anfitriã ou a coordenação do Grupo $number vai analisar o seu pedido.';
  }

  @override
  String get calendarGuestDialogCancel => 'Cancelar';

  @override
  String get calendarGuestDialogConfirm => 'Solicitar';

  @override
  String get calendarGuestRequestSuccess =>
      'Pedido enviado! Agora é só aguardar a aprovação.';

  @override
  String get calendarGuestAlreadyRequested =>
      'Você já pediu para participar deste encontro.';

  @override
  String get calendarGuestAlreadyMember =>
      'Você já tem um vínculo ou pedido com este grupo.';

  @override
  String get calendarGuestRecentlyRejected =>
      'Você poderá pedir de novo 24 horas depois da recusa.';

  @override
  String get calendarGuestMeetingNotOpen =>
      'Este encontro não está mais aberto a pedidos.';

  @override
  String get calendarGuestNoReviewer =>
      'Este encontro ainda não tem quem analise pedidos.';

  @override
  String get calendarGuestMeetingUnavailable =>
      'Este encontro não está disponível para você.';

  @override
  String get calendarGuestMeetingNotFound => 'Este encontro não existe mais.';

  @override
  String get calendarGuestRequestError =>
      'Não foi possível enviar o pedido. Tente novamente.';
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
  String get meetingPhotoCaptionTitle => 'Legenda da foto';

  @override
  String get meetingPhotoCaptionHint => 'Escreva uma legenda para esta foto';

  @override
  String meetingPhotoCaptionCounter(int current, int max) {
    return '$current de $max';
  }

  @override
  String meetingPhotoCaptionTooLong(int max) {
    return 'A legenda deve ter no máximo $max caracteres.';
  }

  @override
  String get meetingPhotoCaptionSave => 'Salvar legenda';

  @override
  String get meetingPhotoCaptionSkip => 'Sem legenda';

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
  String get onboardingBirthDateHint => 'DD/MM/AAAA';

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
  String get clearSearchTooltip => 'Limpar busca';

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
  String get groupNextEventTimeUndefined => '--:--';

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
  String get groupParticipantCoordinatorTag => 'Coordenadora';

  @override
  String get groupParticipantHostTag => 'Anfitriã';

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
  String meetingDetailsTime(String time) {
    return 'Horário: $time';
  }

  @override
  String get meetingDetailsTimeUndefined => 'Horário: a definir';

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
  String get raffleTableHeaderName => 'Participante';

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
  String get raffleErrorMessage =>
      'Não foi possível concluir o sorteio. Tente novamente.';

  @override
  String get raffleNoMoreParticipantsToDraw => 'Sem mais pessoas para sortear';

  @override
  String get raffleNoEligibleParticipants =>
      'Não há participantes elegíveis para o sorteio.';

  @override
  String get raffleSavedSuccessToast =>
      'Sorteio registrado com sucesso! Nova anfitriã definida.';

  @override
  String get meetingPhotoPrevious => 'Foto anterior';

  @override
  String get meetingPhotoNext => 'Próxima foto';

  @override
  String starRatingSemanticLabel(String rating, int maxStars) {
    return '$rating de $maxStars estrelas';
  }

  @override
  String starRatingInputStarLabel(int starValue, int maxStars) {
    return '$starValue de $maxStars estrelas';
  }

  @override
  String bookDetailWrittenBy(String author) {
    return 'Escrito por $author';
  }

  @override
  String get bookDetailNoRatings => 'Ainda sem avaliações';

  @override
  String get notificationsTitle => 'Notificações';

  @override
  String notificationsUnreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count não lidas',
      one: '1 não lida',
    );
    return '$_temp0';
  }

  @override
  String get notificationsBadgeOverflow => '99+';

  @override
  String get notificationsEmpty => 'Nenhuma notificação por aqui';

  @override
  String get notificationsLoadError =>
      'Não foi possível carregar suas notificações.';

  @override
  String get notificationsLoadMoreError =>
      'Não foi possível carregar mais notificações.';

  @override
  String get notificationsRetry => 'Tentar novamente';

  @override
  String get notificationsLoading => 'Carregando notificações';

  @override
  String get notificationsLoadingMore => 'Carregando mais notificações';

  @override
  String notificationTileUnreadSemantic(String title, String message) {
    return 'Não lida: $title. $message';
  }

  @override
  String notificationTileReadSemantic(String title, String message) {
    return '$title. $message';
  }

  @override
  String get notificationDateNow => 'agora';

  @override
  String notificationDateMinutes(int count) {
    return 'há $count min';
  }

  @override
  String notificationDateHours(int count) {
    return 'há $count h';
  }

  @override
  String notificationDateDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count dias',
      one: 'ontem',
    );
    return '$_temp0';
  }

  @override
  String get bookDetailScreenTitle => 'Detalhes do livro';

  @override
  String get bookDetailRateButton => 'Avaliar';

  @override
  String get bookDetailEditReviewButton => 'Editar avaliação';

  @override
  String get bookReviewDialogTitle => 'Avaliar livro';

  @override
  String get bookReviewRatingLabel => 'Sua nota';

  @override
  String get bookReviewCommentLabel => 'Adicione seu comentário (opcional)';

  @override
  String get bookReviewCommentHint => 'Digite sua resposta';

  @override
  String get bookReviewCancel => 'Cancelar';

  @override
  String get bookReviewSubmit => 'Concluir';

  @override
  String get bookReviewSuccess => 'Avaliação salva com sucesso.';

  @override
  String get bookReviewError => 'Não foi possível salvar sua avaliação.';

  @override
  String get bookDetailRecommendButton => 'Indicar';

  @override
  String get bookDetailSynopsisTitle => 'Sinopse';

  @override
  String get bookDetailReviewsTitle => 'Comentários';

  @override
  String get bookDetailNoReviews => 'Ainda não há comentários';

  @override
  String get bookDetailNoSynopsis => 'Este livro ainda não tem sinopse.';

  @override
  String get bookDetailLoading => 'Carregando livro';

  @override
  String get bookDetailLoadError => 'Não foi possível carregar o livro.';

  @override
  String get bookDetailNotFound => 'Livro não encontrado.';

  @override
  String get bookDetailLoadingMoreReviews => 'Carregando mais comentários';

  @override
  String get bookDetailLoadMoreReviewsError =>
      'Não foi possível carregar mais comentários.';

  @override
  String get bookReadingStatusError =>
      'Não foi possível atualizar o status de leitura.';

  @override
  String calendarMonthName(DateTime month) {
    final intl.DateFormat monthDateFormat = intl.DateFormat.LLLL(localeName);
    final String monthString = monthDateFormat.format(month);

    return '$monthString';
  }

  @override
  String calendarMonthSemantic(DateTime month) {
    final intl.DateFormat monthDateFormat = intl.DateFormat.yMMMM(localeName);
    final String monthString = monthDateFormat.format(month);

    return '$monthString';
  }

  @override
  String get calendarPreviousMonth => 'Mês anterior';

  @override
  String get calendarNextMonth => 'Próximo mês';

  @override
  String calendarWeekdayShort(String weekday) {
    String _temp0 = intl.Intl.selectLogic(weekday, {
      'sunday': 'Dom',
      'monday': 'Seg',
      'tuesday': 'Ter',
      'wednesday': 'Qua',
      'thursday': 'Qui',
      'friday': 'Sex',
      'saturday': 'Sáb',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String calendarDaySemantic(DateTime day, int count) {
    final intl.DateFormat dayDateFormat = intl.DateFormat.MMMMd(localeName);
    final String dayString = dayDateFormat.format(day);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count encontros',
      one: '1 encontro',
      zero: 'sem encontros',
    );
    return '$dayString, $_temp0';
  }

  @override
  String get calendarToday => 'Hoje';

  @override
  String get calendarFilterAll => 'Todos';

  @override
  String calendarFilterUpcoming(int count) {
    return 'Próximos eventos ($count)';
  }

  @override
  String get calendarFilterPast => 'Eventos passados';

  @override
  String calendarSelectedDayTitle(DateTime day) {
    final intl.DateFormat dayDateFormat = intl.DateFormat.MMMMEEEEd(localeName);
    final String dayString = dayDateFormat.format(day);

    return '$dayString';
  }

  @override
  String get calendarClearSelectedDay => 'Limpar dia selecionado';

  @override
  String calendarMeetingTitle(int number) {
    return 'Encontro Grupo $number';
  }

  @override
  String calendarMeetingTitleWithDate(DateTime date, int number) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString - Encontro Grupo $number';
  }

  @override
  String calendarMeetingTime(DateTime time) {
    final intl.DateFormat timeDateFormat = intl.DateFormat.Hm(localeName);
    final String timeString = timeDateFormat.format(time);

    return '$timeString';
  }

  @override
  String calendarParticipantsCount(int count) {
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
  String calendarMeetingPlaceWithCity(String place, String city) {
    return '$place, $city';
  }

  @override
  String calendarMeetingHost(String name) {
    return '$name (Anfitriã)';
  }

  @override
  String get calendarLoading => 'Carregando encontros';

  @override
  String get calendarLoadError => 'Não foi possível carregar o calendário.';

  @override
  String get calendarEmptyMonth => 'Nenhum encontro neste mês.';

  @override
  String get calendarEmptyUpcoming => 'Nenhum próximo encontro neste mês.';

  @override
  String get calendarEmptyPast => 'Nenhum encontro passado neste mês.';

  @override
  String get calendarEmptyDay => 'Nenhum encontro neste dia.';

  @override
  String calendarMonthTitle(String month, int year) {
    return '$month $year';
  }

  @override
  String get calendarMeetingDraftTag => 'Rascunho';

  @override
  String get publicGroupTitle => 'Detalhes do grupo';

  @override
  String get publicGroupLoading => 'Carregando grupo';

  @override
  String get publicGroupLoadError => 'Não foi possível carregar o grupo.';

  @override
  String get publicGroupUnavailable => 'Este grupo não está disponível.';

  @override
  String get publicGroupRequestJoin => 'Solicitar entrada';

  @override
  String get publicGroupRequestAgain => 'Pedir novamente';

  @override
  String get publicGroupStatusRequested => 'Aguardando aprovação';

  @override
  String get publicGroupStatusRejected => 'Solicitação recusada';

  @override
  String get publicGroupStatusPending => 'Aguardando criação de conta';

  @override
  String get publicGroupStatusMember => 'Você já faz parte deste grupo';

  @override
  String get publicGroupOpenMemberDetails => 'Ver grupo';

  @override
  String get publicGroupJoinDialogTitle => 'Solicitar entrada?';

  @override
  String publicGroupJoinDialogMessage(int number) {
    return 'A coordenação do Grupo $number vai analisar o seu pedido.';
  }

  @override
  String get publicGroupJoinDialogCancel => 'Cancelar';

  @override
  String get publicGroupJoinDialogConfirm => 'Solicitar';

  @override
  String get publicGroupJoinSuccess =>
      'Pedido enviado! Agora é só aguardar a aprovação.';

  @override
  String get publicGroupJoinAlreadyRequested =>
      'Você já pediu entrada ou já faz parte deste grupo.';

  @override
  String get publicGroupJoinNoCoordinator =>
      'Este grupo ainda não aceita pedidos de entrada.';

  @override
  String get publicGroupJoinError =>
      'Não foi possível enviar o pedido. Tente novamente.';

  @override
  String get searchTabBooks => 'Livros';

  @override
  String get searchTabGroups => 'Grupos';

  @override
  String get groupSearchTitle => 'Encontre seu grupo ideal';

  @override
  String get groupSearchHint => 'Buscar grupo';

  @override
  String get groupSearchFiltersButton => 'Filtros';

  @override
  String get groupSearchFiltersActive => 'Filtros aplicados';

  @override
  String get cityFilterLabel => 'Cidade';

  @override
  String get cityFilterAll => 'Todas as cidades';

  @override
  String cityFilterOption(String name, String uf) {
    return '$name, $uf';
  }

  @override
  String get groupSearchFilterMin => 'Mínimo de participantes';

  @override
  String get groupSearchFilterMinHint => 'Ex.: 10';

  @override
  String get groupSearchFilterMax => 'Máximo de participantes';

  @override
  String get groupSearchFilterMaxHint => 'Ex.: 20';

  @override
  String get groupSearchFilterRangeError =>
      'O mínimo não pode ser maior que o máximo.';

  @override
  String get groupSearchFiltersApply => 'Aplicar filtros';

  @override
  String get groupSearchFiltersClear => 'Limpar filtros';

  @override
  String get groupSearchLoading => 'Carregando grupos';

  @override
  String get groupSearchLoadingMore => 'Carregando mais grupos';

  @override
  String get groupSearchLoadError => 'Não foi possível carregar os grupos.';

  @override
  String get groupSearchLoadMoreError =>
      'Não foi possível carregar mais grupos.';

  @override
  String get groupSearchEmpty => 'Ainda não há grupos ativos.';

  @override
  String get groupSearchEmptyFiltered =>
      'Nenhum grupo encontrado. Tente outra busca ou mude os filtros.';

  @override
  String get groupSearchEnd => 'Você chegou ao fim da lista.';

  @override
  String get groupSearchSeeDetails => 'Ver detalhes';

  @override
  String groupSearchSeeDetailsSemantic(int number) {
    return 'Ver detalhes do Grupo $number';
  }

  @override
  String groupJoinRequestsAccess(int count) {
    return 'Pedidos de entrada ($count)';
  }

  @override
  String get groupJoinRequestsTitle => 'Pedidos de entrada';

  @override
  String get groupJoinRequestsLoading => 'Carregando pedidos de entrada';

  @override
  String get groupJoinRequestsEmpty => 'Nenhum pedido de entrada';

  @override
  String get groupJoinRequestsLoadError =>
      'Não foi possível carregar os pedidos de entrada.';

  @override
  String get groupJoinRequestsNotCoordinator =>
      'Só a coordenação do grupo pode ver os pedidos de entrada.';

  @override
  String get groupJoinRequestsGroupUnavailable =>
      'Este grupo não está disponível.';

  @override
  String groupJoinRequestsRequestedAt(DateTime date, DateTime time) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);
    final intl.DateFormat timeDateFormat = intl.DateFormat.Hm(localeName);
    final String timeString = timeDateFormat.format(time);

    return 'Pedido em $dateString às $timeString';
  }

  @override
  String get groupJoinRequestsApprove => 'Aceitar';

  @override
  String get groupJoinRequestsReject => 'Recusar';

  @override
  String get groupJoinRequestsApproveDialogTitle => 'Aceitar pedido?';

  @override
  String groupJoinRequestsApproveDialogMessage(String name) {
    return '$name vai passar a fazer parte do grupo.';
  }

  @override
  String get groupJoinRequestsRejectDialogTitle => 'Recusar pedido?';

  @override
  String groupJoinRequestsRejectDialogMessage(String name) {
    return '$name não vai entrar no grupo agora, mas poderá pedir de novo.';
  }

  @override
  String get groupJoinRequestsDialogCancel => 'Cancelar';

  @override
  String get groupJoinRequestsApproved =>
      'Pedido aceito! A leitora já faz parte do grupo.';

  @override
  String get groupJoinRequestsRejected => 'Pedido recusado.';

  @override
  String get groupJoinRequestsAlreadyReviewed =>
      'Este pedido já foi respondido.';

  @override
  String get groupJoinRequestsNotFound =>
      'Este pedido não está mais disponível.';

  @override
  String get groupJoinRequestsNoLongerValid =>
      'Este pedido não pode mais ser aceito: o grupo ou a conta da leitora foi desativado.';

  @override
  String get groupJoinRequestsReviewError =>
      'Não foi possível responder ao pedido. Tente novamente.';

  @override
  String groupJoinRequestsApproveSemantics(String name) {
    return 'Aceitar pedido de $name';
  }

  @override
  String groupJoinRequestsRejectSemantics(String name) {
    return 'Recusar pedido de $name';
  }

  @override
  String profileBooksReadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count livros lidos',
      one: '1 livro lido',
      zero: '0 livros lidos',
    );
    return '$_temp0';
  }

  @override
  String profileGroupsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count grupos',
      one: '1 grupo',
      zero: '0 grupos',
    );
    return '$_temp0';
  }

  @override
  String get profileMyGroupsTitle => 'Meus grupos';

  @override
  String profileGroupLabel(int number) {
    return 'Grupo $number';
  }

  @override
  String get profileMoreGroupsButtonLabel => 'Ver mais grupos';

  @override
  String get profileNoGroups => 'Você ainda não participa de nenhum grupo.';

  @override
  String get profileReviewedBooksTitle => 'Livros avaliados';

  @override
  String get profileNoReviewedBooks => 'Você ainda não avaliou nenhum livro.';

  @override
  String get profileSeeAllBooks => 'Ver todos os livros';

  @override
  String get profileSummaryLoading => 'Carregando seus grupos e livros';

  @override
  String get profileSummaryLoadError =>
      'Não foi possível carregar seus grupos e livros.';

  @override
  String get meetingPresenceEmptyConfirmTitle => 'Ninguém compareceu?';

  @override
  String get meetingPresenceEmptyConfirmMessage =>
      'Nenhuma participante está marcada. Ao confirmar, todas ficam com falta e a lista não pode ser alterada depois.';

  @override
  String get meetingPresenceEmptyConfirmCancel => 'Voltar';

  @override
  String get meetingPresenceEmptyConfirmConfirm => 'Confirmar mesmo assim';

  @override
  String profileClubTimeMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meses no clube',
      one: '1 mês no clube',
      zero: 'Chegou ao clube este mês',
    );
    return '$_temp0';
  }

  @override
  String profileClubTimeYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count anos no clube',
      one: '1 ano no clube',
    );
    return '$_temp0';
  }

  @override
  String meetingGuestRequestsAccess(int count) {
    return 'Pedidos de participação ($count)';
  }

  @override
  String get meetingGuestRequestsTitle => 'Pedidos de participação';

  @override
  String get meetingGuestRequestsLoading =>
      'Carregando pedidos de participação';

  @override
  String get meetingGuestRequestsEmpty => 'Nenhum pedido de participação';

  @override
  String get meetingGuestRequestsLoadError =>
      'Não foi possível carregar os pedidos de participação.';

  @override
  String get meetingGuestRequestsNotReviewer =>
      'Só a anfitriã do encontro ou a coordenação do grupo pode ver os pedidos de participação.';

  @override
  String get meetingGuestRequestsMeetingUnavailable =>
      'Este encontro não está disponível.';

  @override
  String meetingGuestRequestsRequestedAt(DateTime date, DateTime time) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);
    final intl.DateFormat timeDateFormat = intl.DateFormat.Hm(localeName);
    final String timeString = timeDateFormat.format(time);

    return 'Pedido em $dateString às $timeString';
  }

  @override
  String get meetingGuestRequestsApprove => 'Aceitar';

  @override
  String get meetingGuestRequestsReject => 'Recusar';

  @override
  String get meetingGuestRequestsApproveDialogTitle => 'Aceitar pedido?';

  @override
  String meetingGuestRequestsApproveDialogMessage(String name) {
    return '$name vai participar deste encontro como convidada.';
  }

  @override
  String get meetingGuestRequestsRejectDialogTitle => 'Recusar pedido?';

  @override
  String meetingGuestRequestsRejectDialogMessage(String name) {
    return '$name não vai participar deste encontro, mas poderá pedir de novo.';
  }

  @override
  String get meetingGuestRequestsDialogCancel => 'Cancelar';

  @override
  String get meetingGuestRequestsApproved =>
      'Pedido aceito! A leitora foi confirmada no encontro.';

  @override
  String get meetingGuestRequestsRejected => 'Pedido recusado.';

  @override
  String get meetingGuestRequestsAlreadyReviewed =>
      'Este pedido já foi respondido.';

  @override
  String get meetingGuestRequestsNotFound =>
      'Este pedido não está mais disponível.';

  @override
  String get meetingGuestRequestsNoLongerValid =>
      'Este pedido não pode mais ser aceito: o encontro foi encerrado, a conta da leitora foi desativada ou ela já faz parte do grupo.';

  @override
  String get meetingGuestRequestsReviewError =>
      'Não foi possível responder ao pedido. Tente novamente.';

  @override
  String meetingGuestRequestsApproveSemantics(String name) {
    return 'Aceitar pedido de participação de $name';
  }

  @override
  String meetingGuestRequestsRejectSemantics(String name) {
    return 'Recusar pedido de participação de $name';
  }

  @override
  String get meetingAttendanceGuestTag => 'Convidada';

  @override
  String get calendarGuestRequest => 'Solicitar participação';

  @override
  String get calendarGuestRequestAgain => 'Pedir novamente';

  @override
  String get calendarGuestStatusRequested => 'Aguardando aprovação';

  @override
  String get calendarGuestStatusAccepted => 'Participação confirmada';

  @override
  String get calendarGuestStatusRejected => 'Pedido recusado';

  @override
  String get calendarGuestDialogTitle => 'Solicitar participação?';

  @override
  String calendarGuestDialogMessage(int number) {
    return 'A anfitriã ou a coordenação do Grupo $number vai analisar o seu pedido.';
  }

  @override
  String get calendarGuestDialogCancel => 'Cancelar';

  @override
  String get calendarGuestDialogConfirm => 'Solicitar';

  @override
  String get calendarGuestRequestSuccess =>
      'Pedido enviado! Agora é só aguardar a aprovação.';

  @override
  String get calendarGuestAlreadyRequested =>
      'Você já pediu para participar deste encontro.';

  @override
  String get calendarGuestAlreadyMember =>
      'Você já tem um vínculo ou pedido com este grupo.';

  @override
  String get calendarGuestRecentlyRejected =>
      'Você poderá pedir de novo 24 horas depois da recusa.';

  @override
  String get calendarGuestMeetingNotOpen =>
      'Este encontro não está mais aberto a pedidos.';

  @override
  String get calendarGuestNoReviewer =>
      'Este encontro ainda não tem quem analise pedidos.';

  @override
  String get calendarGuestMeetingUnavailable =>
      'Este encontro não está disponível para você.';

  @override
  String get calendarGuestMeetingNotFound => 'Este encontro não existe mais.';

  @override
  String get calendarGuestRequestError =>
      'Não foi possível enviar o pedido. Tente novamente.';
}
