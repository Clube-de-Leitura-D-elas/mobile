import 'package:bloc/bloc.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/next_event_state.dart';

class NextEventCubit extends Cubit<NextEventState> {
  NextEventCubit({required this.groupRepository})
    : super(const NextEventLoading());

  final GroupRepository groupRepository;

  Future<void> load(String groupId) async {
    emit(const NextEventLoading());

    final result = await groupRepository.getNextEvent(groupId);
    if (isClosed) return;

    switch (result) {
      case Failure(:final failure):
        emit(NextEventError(failure.message));
      case Success(:final data):
        if (data == null) {
          emit(const NextEventEmpty());
        } else {
          emit(NextEventLoaded(data));
        }
    }
  }
}
