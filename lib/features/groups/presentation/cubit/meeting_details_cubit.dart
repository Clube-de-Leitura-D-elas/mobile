import 'package:bloc/bloc.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_details_state.dart';

class MeetingDetailsCubit extends Cubit<MeetingDetailsState> {
  MeetingDetailsCubit({required this.groupRepository})
    : super(const MeetingDetailsLoading());

  final GroupRepository groupRepository;

  String _meetingId = '';

  Future<void> retry() => load(_meetingId);

  Future<void> load(String meetingId) async {
    _meetingId = meetingId;
    emit(const MeetingDetailsLoading());

    final result = await groupRepository.getMeetingDetails(meetingId);
    if (isClosed) return;

    switch (result) {
      case Failure(:final failure):
        emit(
          MeetingDetailsError(
            failure.message,
            canRetry: failure is! MeetingNotFoundFailure,
          ),
        );
      case Success(:final data):
        emit(MeetingDetailsLoaded(data));
    }
  }
}
