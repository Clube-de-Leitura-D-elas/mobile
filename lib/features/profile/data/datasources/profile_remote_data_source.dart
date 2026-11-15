import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/profile/data/models/profile_summary_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show HttpMethod;

abstract class ProfileRemoteDataSource {
  /// `null` quando a function responde sem corpo.
  Future<Result<ProfileSummaryModel?, SupabaseFailure>> getMyProfileSummary();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl({required this.supabaseService});

  final SupabaseService supabaseService;

  @override
  Future<Result<ProfileSummaryModel?, SupabaseFailure>>
  getMyProfileSummary() async {
    final result = await supabaseService.invokeFunction<ProfileSummaryModel>(
      functionName: 'get-my-profile-summary',
      // A function só aceita GET.
      method: HttpMethod.get,
      decoder: (data) =>
          ProfileSummaryModel.fromJson(data as Map<String, dynamic>),
    );

    return switch (result) {
      Failure(:final failure) => Failure(failure),
      Success(:final data) => Success(data.data),
    };
  }
}
