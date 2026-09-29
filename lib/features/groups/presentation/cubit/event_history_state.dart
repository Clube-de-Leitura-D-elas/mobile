import 'package:equatable/equatable.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';

sealed class EventHistoryState extends Equatable {
  const EventHistoryState();

  @override
  List<Object?> get props => [];
}

class EventHistoryLoading extends EventHistoryState {
  const EventHistoryLoading();
}

class EventHistoryEmpty extends EventHistoryState {
  const EventHistoryEmpty();
}

class EventHistoryLoaded extends EventHistoryState {
  const EventHistoryLoaded(this.meetings);

  final List<GroupMeeting> meetings;

  @override
  List<Object?> get props => [meetings];
}

class EventHistoryError extends EventHistoryState {
  const EventHistoryError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
