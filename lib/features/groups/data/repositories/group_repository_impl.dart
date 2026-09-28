import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/data/models/group_details_model.dart';
import 'package:mobile/features/groups/domain/entities/group_details_entity.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';

class GroupRepositoryImpl implements GroupRepository {
  final SupabaseService supabaseService;

  const GroupRepositoryImpl({required this.supabaseService});

  @override
  Future<Result<GroupDetailsEntity, SupabaseFailure>> getGroupDetails(
    String groupId,
  ) async {
    final result = await supabaseService.invokeFunction<GroupDetailsModel>(
      functionName: 'get-group-details?group_id=$groupId',
      decoder: GroupDetailsModel.fromJson,
    );

    switch (result) {
      case Failure(:final failure):
        return Failure(failure);
      case Success(:final data):
        final group = data.data;
        if (group == null) {
          return Failure(
            FunctionSupabaseFailure(
              message:
                  'A função get-group-details retornou uma resposta vazia.',
              code: data.statusCode.toString(),
            ),
          );
        }
        return Success<GroupDetailsEntity, SupabaseFailure>(group.toDomain());
    }
  }
}
