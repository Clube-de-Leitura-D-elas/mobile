import 'package:bloc/bloc.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/next_event_state.dart';

class NextEventCubit extends Cubit<NextEventState> {
  NextEventCubit({required this.groupRepository})
    : super(const NextEventLoading());

  final GroupRepository groupRepository;

  String _groupId = '';

  Future<void> retry() => load(_groupId);

  Future<void> load(String groupId) async {
    _groupId = groupId;
    emit(const NextEventLoading());

    final result = await groupRepository.getNextEvent(groupId);
    if (isClosed) return;

    switch (result) {
      case Failure(:final failure):
        emit(NextEventError(failure));
      case Success(:final data):
        if (data == null) {
          emit(const NextEventEmpty());
        } else {
          emit(NextEventLoaded(data));
        }
    }
  }
}
