import 'package:equatable/equatable.dart';

/// De quais cidades uma consulta traz grupos ou encontros.
sealed class CityScope extends Equatable {
  const CityScope();

  static const all = AllCitiesScope();

  const factory CityScope.only(String cityId) = SingleCityScope;
}

class AllCitiesScope extends CityScope {
  const AllCitiesScope();

  @override
  List<Object?> get props => [];
}

class SingleCityScope extends CityScope {
  final String cityId;

  const SingleCityScope(this.cityId);

  @override
  List<Object?> get props => [cityId];
}
