import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/features/raffles/presentation/cubit/raffle_execution_cubit.dart';
import 'package:mobile/features/raffles/presentation/pages/raffle_execution_screen.dart';

class RaffleExecutionPage extends StatelessWidget {
  final String meetingId;
  final String meetingTitle;

  const RaffleExecutionPage({
    super.key,
    required this.meetingId,
    this.meetingTitle = '',
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<RaffleExecutionCubit>()
        ..load(meetingId, meetingTitle: meetingTitle),
      child: RaffleExecutionScreen(
        meetingId: meetingId,
        meetingTitle: meetingTitle,
      ),
    );
  }
}
