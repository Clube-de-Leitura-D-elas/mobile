import 'package:equatable/equatable.dart';

sealed class GroupFailure extends Equatable {
  final String message;

  const GroupFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class GroupDetailsFailure extends GroupFailure {
  const GroupDetailsFailure({
    super.message =
        'Não foi possível carregar os detalhes do grupo. Tente novamente.',
  });
}

class GroupListFailure extends GroupFailure {
  const GroupListFailure({
    super.message = 'Não foi possível carregar seus grupos. Tente novamente.',
  });
}

class GroupParticipantsFailure extends GroupFailure {
  const GroupParticipantsFailure({
    super.message = 'Não foi possível carregar as participantes do grupo.',
  });
}

class GroupNotFoundFailure extends GroupFailure {
  const GroupNotFoundFailure({super.message = 'Grupo não encontrado.'});
}

class GroupEventHistoryFailure extends GroupFailure {
  const GroupEventHistoryFailure({
    super.message =
        'Não foi possível carregar o histórico de eventos. Tente novamente.',
  });
}

class MeetingDetailsFailure extends GroupFailure {
  const MeetingDetailsFailure({
    super.message =
        'Não foi possível carregar os detalhes do encontro. Tente novamente.',
  });
}

class MeetingNotFoundFailure extends GroupFailure {
  const MeetingNotFoundFailure({super.message = 'Encontro não encontrado.'});
}

class MeetingAttendanceFailure extends GroupFailure {
  const MeetingAttendanceFailure({
    super.message = 'Não foi possível carregar a lista de presença.',
  });
}

class MeetingPresenceFailure extends GroupFailure {
  const MeetingPresenceFailure({
    super.message = 'Não foi possível registrar a presença. Tente novamente.',
  });
}

class MeetingPresenceForbiddenFailure extends GroupFailure {
  const MeetingPresenceForbiddenFailure({
    super.message = 'Você não tem permissão para registrar a presença.',
  });
}

class MeetingPresenceAlreadyRegisteredFailure extends GroupFailure {
  const MeetingPresenceAlreadyRegisteredFailure({
    super.message = 'A presença deste encontro já foi registrada.',
  });
}

class GroupNextEventFailure extends GroupFailure {
  const GroupNextEventFailure({
    super.message =
        'Não foi possível carregar o próximo evento. Tente novamente.',
  });
}

class GroupMeetingInvitationResponseFailure extends GroupFailure {
  const GroupMeetingInvitationResponseFailure({
    super.message = 'Não foi possível atualizar sua resposta. Tente novamente.',
  });
}

class MeetingPhotosFailure extends GroupFailure {
  const MeetingPhotosFailure({
    super.message = 'Não foi possível carregar as fotos do encontro.',
  });
}

class MeetingPhotoUploadFailure extends GroupFailure {
  const MeetingPhotoUploadFailure({
    super.message = 'Não foi possível enviar a foto.',
  });
}

class MeetingPhotoLimitFailure extends GroupFailure {
  const MeetingPhotoLimitFailure({
    super.message = 'O encontro já atingiu o limite de fotos.',
  });
}

class MeetingPhotoRejectedFailure extends GroupFailure {
  const MeetingPhotoRejectedFailure({
    super.message = 'A foto foi recusada e não pode ser enviada.',
  });
}
