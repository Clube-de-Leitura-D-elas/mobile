import 'package:equatable/equatable.dart';

enum PendingRaffleType { inaugural, pending }

/// Sorteio disponível para a coordenação quando o grupo não tem encontro
/// aberto: o inaugural (grupo sem encontros) ou o pendente de um encontro
/// encerrado sem sorteio.
class PendingRaffle extends Equatable {
  final PendingRaffleType type;
  final String groupId;
  final String? meetingId;

  const PendingRaffle({
    required this.type,
    required this.groupId,
    this.meetingId,
  });

  bool get isInaugural => type == PendingRaffleType.inaugural;

  @override
  List<Object?> get props => [type, groupId, meetingId];
}
