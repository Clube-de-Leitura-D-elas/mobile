import 'package:equatable/equatable.dart';
import 'package:mobile/features/groups/domain/entities/next_event_entity.dart';

sealed class NextEventState extends Equatable {
  const NextEventState();

  @override
  List<Object?> get props => [];
}

class NextEventLoading extends NextEventState {
  const NextEventLoading();
}

/// Grupo não tem próximo evento agendado.
class NextEventEmpty extends NextEventState {
  const NextEventEmpty();
}

class NextEventLoaded extends NextEventState {
  const NextEventLoaded(this.event);

  final NextEventEntity event;

  @override
  List<Object?> get props => [event];
}

class NextEventError extends NextEventState {
  const NextEventError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
