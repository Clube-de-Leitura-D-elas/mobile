import 'package:equatable/equatable.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_participant.dart';

abstract class RafflePreparationState extends Equatable {
  const RafflePreparationState();

  @override
  List<Object?> get props => [];
}

class RafflePreparationInitial extends RafflePreparationState {
  const RafflePreparationInitial();
}

class RafflePreparationLoading extends RafflePreparationState {
  const RafflePreparationLoading();
}

class RafflePreparationLoaded extends RafflePreparationState {
  final List<RaffleParticipant> participants;
  final bool isSubmitting;

  const RafflePreparationLoaded({
    required this.participants,
    this.isSubmitting = false,
  });

  RafflePreparationLoaded copyWith({
    List<RaffleParticipant>? participants,
    bool? isSubmitting,
  }) {
    return RafflePreparationLoaded(
      participants: participants ?? this.participants,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [participants, isSubmitting];
}

class RafflePreparationSuccess extends RafflePreparationState {
  const RafflePreparationSuccess();
}

class RafflePreparationError extends RafflePreparationState {
  final String message;

  const RafflePreparationError(this.message);

  @override
  List<Object?> get props => [message];
}
