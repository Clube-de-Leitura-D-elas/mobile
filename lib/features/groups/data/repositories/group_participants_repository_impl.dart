import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/data/models/group_participant_model.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/group_participant_entity.dart';
import 'package:mobile/features/groups/domain/repository/group_participants_repository.dart';

class GroupParticipantsRepositoryImpl implements GroupParticipantsRepository {
  static const String functionName = 'get-group-participants';

  final SupabaseService supabaseService;

  const GroupParticipantsRepositoryImpl({required this.supabaseService});

  @override
  Future<Result<List<GroupParticipantEntity>, GroupFailure>> getParticipants(
    String groupId,
  ) async {
    final result = await supabaseService
        .invokeFunction<List<GroupParticipantModel>>(
          functionName:
              '$functionName?group_id=${Uri.encodeQueryComponent(groupId)}',
          decoder: GroupParticipantModel.listFromJson,
        );

    switch (result) {
      case Failure():
        return const Failure(GroupParticipantsFailure());
      case Success(:final data):
        final participants = data.data;
        if (participants == null) {
          return const Failure(GroupParticipantsFailure());
        }
        final entities = participants.map((p) => p.toDomain()).toList()
          ..sort(_compareParticipants);
        return Success(entities);
    }
  }

  static int _compareParticipants(
    GroupParticipantEntity a,
    GroupParticipantEntity b,
  ) {
    if (a.isCoordinator != b.isCoordinator) {
      return a.isCoordinator ? -1 : 1;
    }
    return _sortKey(a.name).compareTo(_sortKey(b.name));
  }

  /// Lowercase, accent-insensitive key so "Ágata" sorts next to "Ana".
  static String _sortKey(String name) {
    const accented = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
    const plain = 'aaaaaeeeeiiiiooooouuuucn';
    final buffer = StringBuffer();
    for (final rune in name.toLowerCase().runes) {
      final char = String.fromCharCode(rune);
      final index = accented.indexOf(char);
      buffer.write(index == -1 ? char : plain[index]);
    }
    return buffer.toString();
  }
}
