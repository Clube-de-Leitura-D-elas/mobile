import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/entities/meeting_attendance_entity.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';

abstract class MeetingAttendanceState extends Equatable {
  const MeetingAttendanceState();

  @override
  List<Object?> get props => [];
}

class MeetingAttendanceLoading extends MeetingAttendanceState {}

class MeetingAttendanceLoaded extends MeetingAttendanceState {
  final List<MeetingAttendanceEntity> participants;

  const MeetingAttendanceLoaded(this.participants);

  @override
  List<Object?> get props => [participants];
}

class MeetingAttendanceError extends MeetingAttendanceState {
  final GroupFailure failure;

  const MeetingAttendanceError(this.failure);

  @override
  List<Object?> get props => [failure];
}

class MeetingAttendanceCubit extends Cubit<MeetingAttendanceState> {
  final GroupRepository groupRepository;
  final String meetingId;

  MeetingAttendanceCubit({
    required this.groupRepository,
    required this.meetingId,
  }) : super(MeetingAttendanceLoading());

  Future<void> fetchAttendance() async {
    emit(MeetingAttendanceLoading());
    final result = await groupRepository.getMeetingAttendance(meetingId);
    switch (result) {
      case Failure(:final failure):
        emit(MeetingAttendanceError(failure));
      case Success(:final data):
        emit(MeetingAttendanceLoaded(data));
    }
  }

  Future<bool> conclude() async {
    final result = await groupRepository.concludeMeeting(meetingId);
    return switch (result) {
      Failure() => false,
      Success() => true,
    };
  }
}
