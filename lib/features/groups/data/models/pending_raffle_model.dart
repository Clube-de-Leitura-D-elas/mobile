import 'package:mobile/features/groups/domain/entities/pending_raffle.dart';

/// Lê o `pending_raffle` de `get-my-groups` e `get-group-details`.
abstract final class PendingRaffleModel {
  /// Devolve `null` quando o campo falta, não é um objeto ou não traz
  /// `group_id`.
  static PendingRaffle? fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    final groupId = json['group_id'];
    if (groupId is! String) return null;
    final meetingId = json['meeting_id'];
    return PendingRaffle(
      type: json['type'] == 'INAUGURAL'
          ? PendingRaffleType.inaugural
          : PendingRaffleType.pending,
      groupId: groupId,
      meetingId: meetingId is String ? meetingId : null,
    );
  }
}
