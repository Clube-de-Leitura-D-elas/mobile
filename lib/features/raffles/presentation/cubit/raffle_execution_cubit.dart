import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_failure.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_participant.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_result.dart';
import 'package:mobile/features/raffles/domain/repository/raffle_repository.dart';
import 'package:mobile/features/raffles/presentation/cubit/raffle_execution_state.dart';

class RaffleExecutionCubit extends Cubit<RaffleExecutionState> {
  final RaffleRepository repository;

  RaffleExecutionCubit({required this.repository})
    : super(const RaffleExecutionInitial());

  String _meetingId = '';
  String? _meetingTitle;
  List<RaffleParticipant>? _participants;

  /// Quem a coordenadora escolheu na preparação. A lista rebuscada após um
  /// 422 vem com todas marcadas e não pode trazer de volta quem foi tirado.
  Set<String>? _chosenIds;

  Future<void> retry() => load(
    _meetingId,
    meetingTitle: _meetingTitle,
    participants: _participants,
  );

  Future<void> load(
    String meetingId, {
    String? meetingTitle,
    List<RaffleParticipant>? participants,
  }) async {
    _meetingId = meetingId;
    _meetingTitle = meetingTitle;
    _participants = participants;
    if (participants != null) {
      _chosenIds = {
        for (final p in participants)
          if (p.isSelected) p.id,
      };
    }
    emit(const RaffleExecutionLoading());

    final existingResult = await repository.getRaffleResult(meetingId);
    if (isClosed) return;

    final existing = existingResult.match((res) => res, (failure) {
      emit(RaffleExecutionError(failure));
      return null;
    });
    if (existingResult is Failure<RaffleResult?, RaffleFailure>) return;
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

    if (participants != null) {
      _emitEligible(meetingId, meetingTitle ?? '', participants);
      return;
    }

    final participantsResult = await repository.getEligibleParticipants(
      meetingId,
    );
    if (isClosed) return;

    participantsResult.match(
      (fetched) =>
          _emitEligible(meetingId, meetingTitle ?? '', _keepChosen(fetched)),
      (failure) => emit(RaffleExecutionError(failure)),
    );
  }

  List<RaffleParticipant> _keepChosen(List<RaffleParticipant> fetched) {
    final chosenIds = _chosenIds;
    if (chosenIds == null) return fetched;
    return [
      for (final p in fetched) p.copyWith(isSelected: chosenIds.contains(p.id)),
    ];
  }

  void _onServerFailure(RaffleFailure failure) {
    // Sem isso o "Tentar novamente" sorteia de novo a lista recusada.
    if (failure is RaffleStaleListFailure) _participants = null;
    emit(RaffleExecutionError(failure));
  }

  void _emitEligible(
    String meetingId,
    String meetingTitle,
    List<RaffleParticipant> participants,
  ) {
    final eligible = participants
        .where((p) => p.isSelected && !p.isExcludedByRule)
        .toList();

    emit(
      eligible.isEmpty
          ? RaffleExecutionNoEligible(
              meetingId: meetingId,
              meetingTitle: meetingTitle,
            )
          : RaffleExecutionReady(
              meetingId: meetingId,
              meetingTitle: meetingTitle,
              eligibleParticipants: eligible,
            ),
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
      if (loadedState.eligibleParticipants.isEmpty) return;
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
          eligibleParticipants: eligible
              .where((p) => p.id != raffleResult.winnerId)
              .toList(),
          isPersisted: false,
        ),
      ),
      _onServerFailure,
    );
  }

  Future<void> confirmResult() async {
    if (state is! RaffleExecutionResultLoaded) return;

    final currentState = state as RaffleExecutionResultLoaded;
    emit(currentState.copyWith(isSubmitting: true));

    final saveResult = await repository.saveRaffleResult(currentState.result);
    if (isClosed) return;

    saveResult.match(
      (_) => emit(RaffleExecutionSuccess(currentState.result)),
      _onServerFailure,
    );
  }
}
