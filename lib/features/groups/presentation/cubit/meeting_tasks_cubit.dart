import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/entities/meeting_tasks_entity.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';

sealed class MeetingTasksState extends Equatable {
  const MeetingTasksState();

  @override
  List<Object?> get props => [];
}

class MeetingTasksLoading extends MeetingTasksState {
  const MeetingTasksLoading();
}

class MeetingTasksLoaded extends MeetingTasksState {
  const MeetingTasksLoaded(this.tasks);

  final MeetingTasksEntity tasks;

  @override
  List<Object?> get props => [tasks];
}

class MeetingTasksError extends MeetingTasksState {
  const MeetingTasksError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class MeetingTasksCubit extends Cubit<MeetingTasksState> {
  MeetingTasksCubit({required this.groupRepository, required this.meetingId})
    : super(const MeetingTasksLoading());

  final GroupRepository groupRepository;
  final String meetingId;

  Future<void> load() async {
    emit(const MeetingTasksLoading());
    await _fetch();
  }

  /// Recarrega ao voltar das telas de edição, registro ou presença sem trocar
  /// o conteúdo por um loading.
  Future<void> refresh() => _fetch();

  Future<void> _fetch() async {
    final result = await groupRepository.getMeetingTasks(meetingId);
    if (isClosed) return;

    switch (result) {
      case Failure(:final failure):
        emit(MeetingTasksError(failure.message));
      case Success(:final data):
        emit(MeetingTasksLoaded(data));
    }
  }
}
