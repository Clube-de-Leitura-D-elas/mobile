import 'package:equatable/equatable.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';

sealed class MeetingEditState extends Equatable {
  const MeetingEditState();

  @override
  List<Object?> get props => [];
}

class MeetingEditIdle extends MeetingEditState {
  const MeetingEditIdle();
}

class MeetingEditSubmitting extends MeetingEditState {
  const MeetingEditSubmitting();
}

class MeetingEditSuccess extends MeetingEditState {
  const MeetingEditSuccess();
}

class MeetingEditError extends MeetingEditState {
  const MeetingEditError(this.failure);

  final GroupFailure failure;

  @override
  List<Object?> get props => [failure];
}
