import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/entities/group_details_entity.dart';

abstract class GroupRepository {
  Future<Result<GroupDetailsEntity, SupabaseFailure>> getGroupDetails(String groupId);
}
