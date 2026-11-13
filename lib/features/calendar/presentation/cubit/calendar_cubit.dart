import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/core/tools/sao_paulo_time.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_failure.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_guest_status.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_meeting_entity.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_month.dart';
import 'package:mobile/features/calendar/domain/repository/calendar_repository.dart';
import 'package:mobile/features/calendar/presentation/cubit/calendar_state.dart';

class CalendarCubit extends Cubit<CalendarState> {
  final CalendarRepository repository;
  final DateTime Function() _now;

  /// Só a resposta da requisição mais recente é aplicada.
  int _latestRequest = 0;

  // Pedidos de participação aceitos pelo backend, com a versão em que
  // aconteceram: uma carga iniciada antes deles traria o status antigo.
  int _participationVersion = 0;
  final Map<String, int> _requestedAtVersion = {};

  CalendarCubit({
    required this.repository,
    DateTime Function() now = DateTime.now,
  }) : _now = now,
       super(
         CalendarState(
           month: CalendarMonth.of(toSaoPaulo(now())),
           today: saoPauloDayOf(now()),
         ),
       );

  /// Instante atual, o mesmo relógio usado para separar próximos e passados.
  DateTime get now => _now();

  Future<void> load() => _load(state.month);

  /// Relê o mês em tela sem trocar a lista pelo carregamento.
  Future<void> refresh() => _refresh();

  Future<void> showPreviousMonth() => _load(state.month.previous);

  Future<void> showNextMonth() => _load(state.month.next);

  void selectFilter(CalendarFilter filter) {
    emit(state.copyWith(filter: filter, clearSelectedDay: true));
  }

  /// Tocar de novo no dia selecionado limpa a seleção. Dias de meses
  /// vizinhos não são selecionáveis.
  void selectDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    if (!state.month.contains(normalized)) return;
    if (state.selectedDay == normalized) {
      clearSelectedDay();
      return;
    }
    emit(state.copyWith(selectedDay: normalized));
  }

  void clearSelectedDay() {
    emit(state.copyWith(clearSelectedDay: true));
  }

  Future<void> requestParticipation(String meetingId) async {
    if (isClosed) return;
    // Fora da lista (recarga em andamento) o pedido segue: a leitora já
    // confirmou e o backend valida tudo de novo.
    final meeting = _find(meetingId);
    if (state.requestingIds.contains(meetingId)) return;
    if (meeting != null && !meeting.isOpenAt(_now())) {
      // Começou com o modal aberto: avisa em vez de sumir com o pedido.
      emit(
        state.copyWith(
          participationFailure: const CalendarMeetingNotOpenFailure(),
        ),
      );
      return;
    }
    if (meeting != null && !meeting.canRequestParticipationAt(_now())) return;

    emit(
      state.copyWith(
        requestingIds: {...state.requestingIds, meetingId},
        participationRequested: false,
        clearParticipationFailure: true,
      ),
    );

    final result = await repository.requestParticipation(meetingId);
    if (isClosed) return;

    switch (result) {
      case Success():
        _requestedAtVersion[meetingId] = ++_participationVersion;
        emit(
          _asRequested(meetingId).copyWith(
            requestingIds: _without(meetingId),
            participationRequested: true,
          ),
        );
      case Failure(:final failure) when _isStale(failure):
        // O card segue ocupado até o status real chegar.
        emit(state.copyWith(participationFailure: failure));
        await _refresh();
        if (isClosed) return;
        emit(state.copyWith(requestingIds: _without(meetingId)));
      case Failure(:final failure):
        emit(
          state.copyWith(
            requestingIds: _without(meetingId),
            participationFailure: failure,
          ),
        );
    }
  }

  void clearParticipationFeedback() {
    emit(
      state.copyWith(
        participationRequested: false,
        clearParticipationFailure: true,
      ),
    );
  }

  /// Falhas que dizem que o mês na tela está velho: o encontro mudou, sumiu
  /// ou a leitora já tem pedido ou vínculo.
  static bool _isStale(CalendarFailure failure) => switch (failure) {
    CalendarGuestAlreadyRequestedFailure() ||
    CalendarGuestAlreadyMemberFailure() ||
    CalendarMeetingNotOpenFailure() ||
    CalendarMeetingUnavailableFailure() ||
    CalendarMeetingNotFoundFailure() => true,
    _ => false,
  };

  /// Relê o mês sem trocar a lista pelo carregamento. Se outra carga está em
  /// andamento (troca de mês), ela já traz o status atual.
  Future<void> _refresh() async {
    if (state.status != CalendarStatus.loaded) return;
    await _load(state.month, silent: true);
  }

  CalendarMeetingEntity? _find(String meetingId) {
    for (final meeting in state.meetings) {
      if (meeting.id == meetingId) return meeting;
    }
    return null;
  }

  CalendarState _asRequested(String meetingId) {
    List<CalendarMeetingEntity> update(List<CalendarMeetingEntity> list) => [
      for (final meeting in list)
        meeting.id == meetingId ? _withLocalStatus(meeting) : meeting,
    ];
    return state.copyWith(
      meetings: update(state.meetings),
      upcoming: update(state.upcoming),
      past: update(state.past),
    );
  }

  Set<String> _without(String meetingId) => {
    for (final id in state.requestingIds)
      if (id != meetingId) id,
  };

  /// Pedido feito depois que a carga começou: a resposta dela não o conhece.
  CalendarMeetingEntity _withLocalRequest(
    CalendarMeetingEntity meeting,
    int loadVersion,
  ) {
    final requestedAt = _requestedAtVersion[meeting.id];
    if (requestedAt == null || requestedAt <= loadVersion) return meeting;
    return _withLocalStatus(meeting);
  }

  /// Um status mais novo vindo do backend (aceito, por exemplo) vence o
  /// "aguardando" local.
  static CalendarMeetingEntity _withLocalStatus(CalendarMeetingEntity meeting) {
    final status = meeting.guestStatus;
    if (status != null && status != CalendarGuestStatus.rejected) {
      return meeting;
    }
    return meeting.asRequested();
  }

  /// O dia selecionado sobrevive à recarga do mesmo mês (inclusive ao
  /// "tentar novamente") e a uma seleção feita durante o carregamento, com
  /// sucesso ou erro; trocar de mês limpa.
  ///
  /// [silent] mantém a lista na tela até a resposta chegar, e uma falha
  /// mantém o que já está nela.
  Future<void> _load(CalendarMonth month, {bool silent = false}) async {
    final request = ++_latestRequest;
    final loadVersion = _participationVersion;
    final now = _now();
    if (!silent) {
      emit(
        CalendarState(
          month: month,
          today: saoPauloDayOf(now),
          filter: state.filter,
          selectedDay: month == state.month ? state.selectedDay : null,
          requestingIds: state.requestingIds,
          participationRequested: state.participationRequested,
          participationFailure: state.participationFailure,
        ),
      );
    }

    final result = await repository.getMeetings(
      from: month.firstVisibleDay,
      to: month.lastVisibleDay,
    );
    if (isClosed || request != _latestRequest) return;

    switch (result) {
      case Failure() when silent:
        return;
      case Failure(:final failure):
        emit(
          CalendarState(
            month: month,
            today: state.today,
            filter: state.filter,
            selectedDay: state.selectedDay,
            status: CalendarStatus.error,
            failure: failure,
            requestingIds: state.requestingIds,
            participationRequested: state.participationRequested,
            participationFailure: state.participationFailure,
          ),
        );
      case Success(:final data):
        final meetings = [
          for (final meeting in data) _withLocalRequest(meeting, loadVersion),
        ]..sort((a, b) => a.date.compareTo(b.date));
        final ofMonth = meetings.where(
          (meeting) => month.contains(meeting.localDate),
        );
        emit(
          CalendarState(
            month: month,
            today: state.today,
            filter: state.filter,
            selectedDay: state.selectedDay,
            status: CalendarStatus.loaded,
            meetings: meetings,
            upcoming: [
              for (final meeting in ofMonth)
                if (meeting.isUpcomingAt(now)) meeting,
            ],
            past: [
              for (final meeting in ofMonth)
                if (!meeting.isUpcomingAt(now)) meeting,
            ],
            requestingIds: state.requestingIds,
            participationRequested: state.participationRequested,
            participationFailure: state.participationFailure,
          ),
        );
    }
  }
}
