import 'package:flutter/foundation.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/cities/data/models/discovery_cities_model.dart';
import 'package:mobile/features/cities/domain/entities/cities_failure.dart';
import 'package:mobile/features/cities/domain/entities/discovery_cities_entity.dart';
import 'package:mobile/features/cities/domain/repository/discovery_cities_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DiscoveryCitiesRepositoryImpl implements DiscoveryCitiesRepository {
  DiscoveryCitiesRepositoryImpl({required this.supabaseService});

  final SupabaseService supabaseService;

  @override
  Future<Result<DiscoveryCitiesEntity, CitiesFailure>> getCities() async {
    final result = await supabaseService.invokeFunction<DiscoveryCitiesModel>(
      functionName: 'get-discovery-cities',
      method: HttpMethod.get,
      decoder: (data) =>
          DiscoveryCitiesModel.fromJson(data as Map<String, dynamic>),
    );

    switch (result) {
      case Failure(:final failure):
        debugPrint('[CitiesFailure] ${failure.message} (${failure.code})');
        return const Failure(CitiesFailure());
      case Success(:final data):
        final model = data.data;
        if (model == null) return const Failure(CitiesFailure());
        return Success(model.toDomain());
    }
  }
}
