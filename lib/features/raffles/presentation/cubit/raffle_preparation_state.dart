import 'package:equatable/equatable.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_failure.dart';
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

  /// Por que a lista acabou de ser recarregada depois de o servidor recusar
  /// a anterior. Só vale na emissão que traz a lista nova.
  final RaffleFailure? refreshedBecause;

  const RafflePreparationLoaded({
    required this.participants,
    this.isSubmitting = false,
    this.refreshedBecause,
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
  List<Object?> get props => [participants, isSubmitting, refreshedBecause];
}

class RafflePreparationSuccess extends RafflePreparationState {
  final List<RaffleParticipant> selectedParticipants;

  const RafflePreparationSuccess({this.selectedParticipants = const []});

  @override
  List<Object?> get props => [selectedParticipants];
}

class RafflePreparationError extends RafflePreparationState {
  final RaffleFailure failure;

  const RafflePreparationError(this.failure);

  @override
  List<Object?> get props => [failure];
}
