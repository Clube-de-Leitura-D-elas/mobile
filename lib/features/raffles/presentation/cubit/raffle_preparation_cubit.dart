import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/raffles/domain/repository/raffle_repository.dart';
import 'package:mobile/features/raffles/presentation/cubit/raffle_preparation_state.dart';

class RafflePreparationCubit extends Cubit<RafflePreparationState> {
  final RaffleRepository repository;

  RafflePreparationCubit({required this.repository})
    : super(const RafflePreparationInitial());

  Future<void> loadEligibleParticipants(String meetingId) async {
    emit(const RafflePreparationLoading());

    final result = await repository.getEligibleParticipants(meetingId);
    if (isClosed) return;

    result.match(
      (participants) =>
          emit(RafflePreparationLoaded(participants: participants)),
      (failure) => emit(RafflePreparationError(failure.message)),
    );
  }

  void toggleParticipantSelection(String participantId) {
    if (state is! RafflePreparationLoaded) return;

    final currentState = state as RafflePreparationLoaded;
    final updatedList = currentState.participants.map((participant) {
      if (participant.id == participantId) {
        if (participant.isExcludedByRule) return participant;
        return participant.copyWith(isSelected: !participant.isSelected);
      }
      return participant;
    }).toList();

    emit(currentState.copyWith(participants: updatedList));
  }

  Future<void> confirmRaffle(String meetingId) async {
    if (state is! RafflePreparationLoaded) return;

    final currentState = state as RafflePreparationLoaded;

    final selectedIds = currentState.participants
        .where((p) => p.isSelected)
        .map((p) => p.id)
        .toList();

    if (selectedIds.isEmpty) return;

    emit(currentState.copyWith(isSubmitting: true));

    final result = await repository.confirmRaffle(
      meetingId: meetingId,
      selectedParticipantIds: selectedIds,
    );
    if (isClosed) return;

    result.match((_) => emit(const RafflePreparationSuccess()), (failure) {
      emit(RafflePreparationError(failure.message));
      emit(currentState.copyWith(isSubmitting: false));
    });
  }
}
