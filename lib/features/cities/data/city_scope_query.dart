import 'package:mobile/features/cities/domain/entities/city_scope.dart';

/// Valor do `cityId` nas functions que filtram por cidade; `null` fica fora
/// da query e o backend usa a cidade da leitora.
String? cityIdQueryValue(CityScope? scope) => switch (scope) {
  null => null,
  AllCitiesScope() => 'all',
  SingleCityScope(:final cityId) => cityId,
};
