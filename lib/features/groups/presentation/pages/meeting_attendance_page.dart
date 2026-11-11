import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_attendance_cubit.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_attendance_screen.dart';
import 'package:mobile/features/groups/presentation/widgets/group_error_state.dart';

class MeetingAttendancePage extends StatelessWidget {
  final String meetingId;
  final String meetingName;
  final String formattedDate;
  final bool concludeOnFinish;

  const MeetingAttendancePage({
    super.key,
    required this.meetingId,
    required this.meetingName,
    required this.formattedDate,
    this.concludeOnFinish = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MeetingAttendanceCubit(
        groupRepository: serviceLocator<GroupRepository>(),
        meetingId: meetingId,
      )..fetchAttendance(),
      child: BlocBuilder<MeetingAttendanceCubit, MeetingAttendanceState>(
        builder: (context, state) {
          return switch (state) {
            MeetingAttendanceLoading() => Scaffold(
              appBar: ScreenHeader.back(title: meetingName),
              body: const Center(child: CircularProgressIndicator()),
            ),
            MeetingAttendanceError(:final failure) => Scaffold(
              appBar: ScreenHeader.back(title: meetingName),
              body: GroupErrorState(
                failure: failure,
                onRetry: () =>
                    context.read<MeetingAttendanceCubit>().fetchAttendance(),
              ),
            ),
            MeetingAttendanceLoaded(:final participants) =>
              MeetingAttendanceScreen(
                meetingName: meetingName,
                formattedDate: formattedDate,
                participants: participants,
                // Aberta pelo "Encerrar encontro": só aqui o encontro é
                // encerrado. Voltar sem concluir não muda o status.
                onComplete: concludeOnFinish
                    ? () async {
                        final concluded = await context
                            .read<MeetingAttendanceCubit>()
                            .conclude();
                        if (!context.mounted) return;
                        if (concluded) {
                          Navigator.of(context).pop(true);
                        } else {
                          context.showErrorToast(
                            const MeetingConclusionFailure().message,
                          );
                        }
                      }
                    : null,
              ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}
