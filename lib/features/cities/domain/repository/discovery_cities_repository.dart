import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/cities/domain/entities/cities_failure.dart';
import 'package:mobile/features/cities/domain/entities/discovery_cities_entity.dart';

abstract class DiscoveryCitiesRepository {
  Future<Result<DiscoveryCitiesEntity, CitiesFailure>> getCities();
}
