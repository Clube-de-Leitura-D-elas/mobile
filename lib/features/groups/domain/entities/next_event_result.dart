import 'package:equatable/equatable.dart';
import 'package:mobile/features/groups/domain/entities/next_event_entity.dart';

class NextEventResult extends Equatable {
  const NextEventResult._({this.event, this.draftMeetingId});

  const NextEventResult.empty() : this._();

  const NextEventResult.inPreparation({required String meetingId})
    : this._(draftMeetingId: meetingId);

  const NextEventResult.loaded(NextEventEntity event) : this._(event: event);

  final NextEventEntity? event;
  final String? draftMeetingId;

  bool get isInPreparation => draftMeetingId != null;

  bool get isEmpty => event == null && !isInPreparation;

  @override
  List<Object?> get props => [event, draftMeetingId];
}
