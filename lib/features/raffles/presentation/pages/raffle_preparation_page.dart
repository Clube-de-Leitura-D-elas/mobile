import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_participant.dart';
import 'package:mobile/features/raffles/presentation/cubit/raffle_preparation_cubit.dart';
import 'package:mobile/features/raffles/presentation/pages/raffle_preparation_screen.dart';

class RafflePreparationPage extends StatelessWidget {
  final String meetingId;
  final String? groupId;
  final String meetingTitle;
  final List<RaffleParticipant>? participants;

  const RafflePreparationPage({
    super.key,
    this.meetingId = '',
    this.groupId,
    this.meetingTitle = '',
    this.participants,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = serviceLocator<RafflePreparationCubit>();
        final known = participants;
        final isInaugural =
            meetingId.isEmpty && groupId != null && groupId!.isNotEmpty;
        if (known != null) {
          cubit.setParticipants(known, isInaugural: isInaugural);
        } else {
          cubit.loadEligibleParticipants(meetingId, groupId);
        }
        return cubit;
      },
      child: RafflePreparationScreen(
        meetingId: meetingId,
        groupId: groupId,
        meetingTitle: meetingTitle,
      ),
    );
  }
}
