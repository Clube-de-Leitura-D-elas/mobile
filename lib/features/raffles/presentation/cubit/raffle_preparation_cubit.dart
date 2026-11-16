import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_failure.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_participant.dart';
import 'package:mobile/features/raffles/domain/repository/raffle_repository.dart';
import 'package:mobile/features/raffles/presentation/cubit/raffle_preparation_state.dart';

class RafflePreparationCubit extends Cubit<RafflePreparationState> {
  final RaffleRepository repository;

  RafflePreparationCubit({required this.repository})
    : super(const RafflePreparationInitial());

  String? _meetingId;
  String? _groupId;

  /// Escolha da coordenadora antes de o servidor recusar a lista. A lista
  /// rebuscada vem com todas marcadas e não pode trazer de volta quem saiu.
  Set<String>? _chosenIds;

  /// Motivo da recusa, para avisar quando a lista nova chegar.
  RaffleFailure? _refreshReason;

  bool get _isInaugural =>
      (_meetingId == null || _meetingId!.isEmpty) &&
      _groupId != null &&
      _groupId!.isNotEmpty;

  Future<void> loadEligibleParticipants(
    String? meetingId, [
    String? groupId,
  ]) {
    _meetingId = meetingId;
    _groupId = groupId;
    _chosenIds = null;
    _refreshReason = null;
    return _load();
  }

  /// Repete a última busca, mantendo a escolha guardada.
  Future<void> retry() => _load();

  Future<void> _load() async {
    emit(const RafflePreparationLoading());

    final result = await repository.getEligibleParticipants(
      _meetingId,
      _groupId,
    );
    if (isClosed) return;

    switch (result) {
      case Failure(:final failure):
        emit(RafflePreparationError(failure));
      case Success(data: final participants):
        final chosenIds = _chosenIds;
        emit(
          RafflePreparationLoaded(
            participants: chosenIds == null
                ? participants
                : [
                    for (final p in participants)
                      p.copyWith(
                        isSelected:
                            !p.isExcludedByRule && chosenIds.contains(p.id),
                      ),
                  ],
            isInaugural: _isInaugural,
            refreshedBecause: _refreshReason,
          ),
        );
        _refreshReason = null;
    }
  }

  void setParticipants(
    List<RaffleParticipant> participants, {
    bool isInaugural = false,
  }) {
    emit(
      RafflePreparationLoaded(
        participants: [
          for (final participant in participants)
            if (participant.isExcludedByRule && participant.isSelected)
              participant.copyWith(isSelected: false)
            else
              participant,
        ],
        isInaugural: isInaugural,
      ),
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

  Future<void> confirmRaffle([String? meetingId, String? groupId]) async {
    if (state is! RafflePreparationLoaded) return;

    final currentState = state as RafflePreparationLoaded;

    final selected = currentState.participants
        .where((p) => p.isSelected)
        .toList();
    final selectedIds = selected.map((p) => p.id).toList();

    if (selectedIds.isEmpty) return;

    emit(currentState.copyWith(isSubmitting: true));

    final targetMeetingId = meetingId ?? _meetingId;
    final targetGroupId = groupId ?? _groupId;

    final result = await repository.confirmRaffle(
      meetingId: targetMeetingId,
      groupId: targetGroupId,
      selectedParticipantIds: selectedIds,
    );
    if (isClosed) return;

    switch (result) {
      case Success():
        emit(RafflePreparationSuccess(selectedParticipants: selected));
      // O resultado já existe: a tela do sorteio carrega e mostra.
      case Failure(failure: RaffleAlreadyRecordedFailure()):
        emit(RafflePreparationSuccess(selectedParticipants: selected));
      case Failure(failure: final RaffleStaleListFailure failure):
        _meetingId = targetMeetingId;
        _groupId = targetGroupId;
        _chosenIds = selectedIds.toSet();
        _refreshReason = failure;
        await _load();
      case Failure(:final failure):
        emit(RafflePreparationError(failure));
        emit(currentState.copyWith(isSubmitting: false));
    }
  }
}
