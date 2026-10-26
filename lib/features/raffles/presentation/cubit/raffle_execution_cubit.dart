import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_participant.dart';
import 'package:mobile/features/raffles/domain/repository/raffle_repository.dart';
import 'package:mobile/features/raffles/presentation/cubit/raffle_execution_state.dart';

class RaffleExecutionCubit extends Cubit<RaffleExecutionState> {
  final RaffleRepository repository;

  RaffleExecutionCubit({required this.repository})
    : super(const RaffleExecutionInitial());

  Future<void> load(String meetingId, {String? meetingTitle}) async {
    emit(const RaffleExecutionLoading());

    final existingResult = await repository.getRaffleResult(meetingId);
    if (isClosed) return;

    final existing = existingResult.match((res) => res, (_) => null);
    if (existing != null) {
      emit(
        RaffleExecutionResultLoaded(
          meetingId: meetingId,
          meetingTitle: meetingTitle ?? '',
          result: existing,
          isPersisted: true,
        ),
      );
      return;
    }

    final participantsResult = await repository.getEligibleParticipants(
      meetingId,
    );
    if (isClosed) return;

    participantsResult.match(
      (participants) {
        final eligible =
            participants
                .where((p) => p.isSelected && !p.isExcludedByRule)
                .toList();

        if (eligible.isEmpty) {
          emit(
            RaffleExecutionNoEligible(
              meetingId: meetingId,
              meetingTitle: meetingTitle ?? '',
            ),
          );
        } else {
          emit(
            RaffleExecutionReady(
              meetingId: meetingId,
              meetingTitle: meetingTitle ?? '',
              eligibleParticipants: eligible,
            ),
          );
        }
      },
      (failure) => emit(RaffleExecutionError(failure.message)),
    );
  }

  Future<void> draw() async {
    String meetingId = '';
    String meetingTitle = '';
    List<RaffleParticipant> eligible = [];

    if (state is RaffleExecutionReady) {
      final readyState = state as RaffleExecutionReady;
      meetingId = readyState.meetingId;
      meetingTitle = readyState.meetingTitle;
      eligible = readyState.eligibleParticipants;
    } else if (state is RaffleExecutionResultLoaded) {
      final loadedState = state as RaffleExecutionResultLoaded;
      meetingId = loadedState.meetingId;
      meetingTitle = loadedState.meetingTitle;
      eligible = loadedState.eligibleParticipants;
    } else {
      return;
    }

    if (eligible.isEmpty) {
      emit(
        RaffleExecutionNoEligible(
          meetingId: meetingId,
          meetingTitle: meetingTitle,
        ),
      );
      return;
    }

    if (state is RaffleExecutionReady) {
      emit((state as RaffleExecutionReady).copyWith(isDrawing: true));
    } else if (state is RaffleExecutionResultLoaded) {
      emit((state as RaffleExecutionResultLoaded).copyWith(isSubmitting: true));
    }

    final drawResult = await repository.drawRaffle(
      meetingId: meetingId,
      eligibleParticipantIds: eligible.map((p) => p.id).toList(),
    );
    if (isClosed) return;

    drawResult.match(
      (raffleResult) => emit(
        RaffleExecutionResultLoaded(
          meetingId: meetingId,
          meetingTitle: meetingTitle,
          result: raffleResult,
          eligibleParticipants: eligible,
          isPersisted: false,
        ),
      ),
      (failure) => emit(RaffleExecutionError(failure.message)),
    );
  }

  Future<void> confirmResult() async {
    if (state is! RaffleExecutionResultLoaded) return;

    final currentState = state as RaffleExecutionResultLoaded;
    emit(currentState.copyWith(isSubmitting: true));

    final saveResult = await repository.saveRaffleResult(currentState.result);
    if (isClosed) return;

    saveResult.match(
      (_) {
        emit(RaffleExecutionSuccess(currentState.result));
        emit(currentState.copyWith(isSubmitting: false, isPersisted: true));
      },
      (failure) {
        emit(RaffleExecutionError(failure.message));
        emit(currentState.copyWith(isSubmitting: false));
      },
    );
  }
}
