import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/features/raffles/presentation/cubit/raffle_preparation_cubit.dart';
import 'package:mobile/features/raffles/presentation/pages/raffle_preparation_screen.dart';

class RafflePreparationPage extends StatelessWidget {
  final String meetingId;

  const RafflePreparationPage({super.key, required this.meetingId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          serviceLocator<RafflePreparationCubit>()
            ..loadEligibleParticipants(meetingId),
      child: RafflePreparationScreen(meetingId: meetingId),
    );
  }
}
