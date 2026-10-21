import 'package:equatable/equatable.dart';

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
  const MeetingEditError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
