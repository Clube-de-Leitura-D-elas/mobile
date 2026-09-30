import 'package:equatable/equatable.dart';
import 'package:mobile/features/groups/domain/entities/group_participant_entity.dart';

sealed class GroupParticipantsState extends Equatable {
  const GroupParticipantsState();

  @override
  List<Object?> get props => [];
}

class GroupParticipantsLoading extends GroupParticipantsState {
  const GroupParticipantsLoading();
}

class GroupParticipantsLoaded extends GroupParticipantsState {
  final List<GroupParticipantEntity> participants;

  const GroupParticipantsLoaded(this.participants);

  @override
  List<Object?> get props => [participants];
}

/// The group has no participants besides its coordinator(s).
class GroupParticipantsEmpty extends GroupParticipantsState {
  const GroupParticipantsEmpty();
}

class GroupParticipantsError extends GroupParticipantsState {
  final String message;

  const GroupParticipantsError(this.message);

  @override
  List<Object?> get props => [message];
}
