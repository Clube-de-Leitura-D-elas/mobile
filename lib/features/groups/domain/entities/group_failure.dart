import 'package:equatable/equatable.dart';

sealed class GroupFailure extends Equatable {
  final String message;

  const GroupFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class GroupDetailsFailure extends GroupFailure {
  const GroupDetailsFailure({
    super.message =
        'Não foi possível carregar os detalhes do grupo. Tente novamente.',
  });
}

class GroupNotFoundFailure extends GroupFailure {
  const GroupNotFoundFailure({super.message = 'Grupo não encontrado.'});
}

class GroupEventHistoryFailure extends GroupFailure {
  const GroupEventHistoryFailure({
    super.message =
        'Não foi possível carregar o histórico de eventos. Tente novamente.',
  });
}
