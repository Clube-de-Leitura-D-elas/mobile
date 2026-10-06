import 'package:equatable/equatable.dart';
import 'package:mobile/features/groups/domain/entities/meeting_details_entity.dart';

sealed class MeetingDetailsState extends Equatable {
  const MeetingDetailsState();

  @override
  List<Object?> get props => [];
}

class MeetingDetailsLoading extends MeetingDetailsState {
  const MeetingDetailsLoading();
}

class MeetingDetailsLoaded extends MeetingDetailsState {
  const MeetingDetailsLoaded(this.meeting);

  final MeetingDetailsEntity meeting;

  @override
  List<Object?> get props => [meeting];
}

class MeetingDetailsError extends MeetingDetailsState {
  const MeetingDetailsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
