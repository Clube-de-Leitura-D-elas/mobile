import 'package:equatable/equatable.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_participant.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_result.dart';

sealed class RaffleExecutionState extends Equatable {
  const RaffleExecutionState();

  @override
  List<Object?> get props => [];
}

class RaffleExecutionInitial extends RaffleExecutionState {
  const RaffleExecutionInitial();
}

class RaffleExecutionLoading extends RaffleExecutionState {
  const RaffleExecutionLoading();
}

class RaffleExecutionNoEligible extends RaffleExecutionState {
  final String meetingId;
  final String meetingTitle;

  const RaffleExecutionNoEligible({
    required this.meetingId,
    this.meetingTitle = '',
  });

  @override
  List<Object?> get props => [meetingId, meetingTitle];
}

class RaffleExecutionReady extends RaffleExecutionState {
  final String meetingId;
  final String meetingTitle;
  final List<RaffleParticipant> eligibleParticipants;
  final bool isDrawing;

  const RaffleExecutionReady({
    required this.meetingId,
    required this.meetingTitle,
    required this.eligibleParticipants,
    this.isDrawing = false,
  });

  RaffleExecutionReady copyWith({
    String? meetingId,
    String? meetingTitle,
    List<RaffleParticipant>? eligibleParticipants,
    bool? isDrawing,
  }) {
    return RaffleExecutionReady(
      meetingId: meetingId ?? this.meetingId,
      meetingTitle: meetingTitle ?? this.meetingTitle,
      eligibleParticipants: eligibleParticipants ?? this.eligibleParticipants,
      isDrawing: isDrawing ?? this.isDrawing,
    );
  }

  @override
  List<Object?> get props => [
    meetingId,
    meetingTitle,
    eligibleParticipants,
    isDrawing,
  ];
}

class RaffleExecutionResultLoaded extends RaffleExecutionState {
  final String meetingId;
  final String meetingTitle;
  final RaffleResult result;
  final List<RaffleParticipant> eligibleParticipants;
  final bool isPersisted;
  final bool isSubmitting;

  const RaffleExecutionResultLoaded({
    required this.meetingId,
    required this.meetingTitle,
    required this.result,
    this.eligibleParticipants = const [],
    this.isPersisted = false,
    this.isSubmitting = false,
  });

  RaffleExecutionResultLoaded copyWith({
    String? meetingId,
    String? meetingTitle,
    RaffleResult? result,
    List<RaffleParticipant>? eligibleParticipants,
    bool? isPersisted,
    bool? isSubmitting,
  }) {
    return RaffleExecutionResultLoaded(
      meetingId: meetingId ?? this.meetingId,
      meetingTitle: meetingTitle ?? this.meetingTitle,
      result: result ?? this.result,
      eligibleParticipants: eligibleParticipants ?? this.eligibleParticipants,
      isPersisted: isPersisted ?? this.isPersisted,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
    meetingId,
    meetingTitle,
    result,
    eligibleParticipants,
    isPersisted,
    isSubmitting,
  ];
}

class RaffleExecutionSuccess extends RaffleExecutionState {
  final RaffleResult result;

  const RaffleExecutionSuccess(this.result);

  @override
  List<Object?> get props => [result];
}

class RaffleExecutionError extends RaffleExecutionState {
  final String message;

  const RaffleExecutionError(this.message);

  @override
  List<Object?> get props => [message];
}
