import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/data/models/group_details_model.dart';
import 'package:mobile/features/groups/data/models/group_model.dart';
import 'package:mobile/features/groups/domain/entities/group_details_entity.dart';
import 'package:mobile/features/groups/domain/entities/group_entity.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';

class GroupRepositoryImpl implements GroupRepository {
  final SupabaseService supabaseService;

  const GroupRepositoryImpl({required this.supabaseService});

  @override
  Future<Result<List<GroupEntity>, GroupFailure>> getMyGroups() async {
    final result = await supabaseService.invokeFunction<List<GroupModel>>(
      functionName: 'get-my-groups',
      decoder: GroupModel.listFromJson,
    );

    switch (result) {
      case Failure():
        return const Failure(GroupListFailure());
      case Success(:final data):
        final groups = data.data;
        if (groups == null) {
          return const Failure(GroupListFailure());
        }
        return Success(groups.map((group) => group.toDomain()).toList());
    }
  }

  @override
  Future<Result<GroupDetailsEntity, GroupFailure>> getGroupDetails(
    String groupId,
  ) async {
    final result = await supabaseService.invokeFunction<GroupDetailsModel>(
      functionName: 'get-group-details?group_id=$groupId',
      decoder: GroupDetailsModel.fromJson,
    );

    switch (result) {
      case Failure(:final failure):
        if (failure is NotFoundSupabaseFailure || failure.code == '404') {
          return const Failure(GroupNotFoundFailure());
        }
        return const Failure(GroupDetailsFailure());
      case Success(:final data):
        final group = data.data;
        if (group == null) {
          return const Failure(GroupDetailsFailure());
        }
        return Success<GroupDetailsEntity, GroupFailure>(group.toDomain());
    }
  }
}
