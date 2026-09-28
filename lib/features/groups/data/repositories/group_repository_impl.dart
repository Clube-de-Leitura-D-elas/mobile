import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/entities/group_details_entity.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';

class GroupRepositoryImpl implements GroupRepository {
  final SupabaseService supabaseService;

  const GroupRepositoryImpl({required this.supabaseService});

  @override
  Future<Result<GroupDetailsEntity, SupabaseFailure>> getGroupDetails(String groupId) async {
    final result = await supabaseService.invokeFunction<GroupDetailsEntity>(
      functionName: 'get-group-details?group_id=$groupId',
      decoder: (json) => GroupDetailsEntity(
        name: json['name'] as String,
        genres: List<String>.from(json['genres'] as List),
        participantCount: json['participant_count'] as int,
        city: json['city'] as String? ?? '',
        stateCode: json['state_code'] as String? ?? '',
        coverImageUrl: json['cover_image_url'] as String?,
      ),
    );

    return switch (result) {
      Success(:final data) => Success(data.data!),
      Failure(:final failure) => Failure(failure),
    };
  }
}
