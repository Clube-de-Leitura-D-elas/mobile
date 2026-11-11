import 'package:equatable/equatable.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
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
  EventHistoryLoaded(List<GroupMeeting> meetings)
    : meetings = List.unmodifiable(meetings);

  final List<GroupMeeting> meetings;

  @override
  List<Object?> get props => [meetings];
}

class EventHistoryError extends EventHistoryState {
  const EventHistoryError(this.failure);

  final GroupFailure failure;

  @override
  List<Object?> get props => [failure];
}
