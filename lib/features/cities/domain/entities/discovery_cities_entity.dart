import 'package:equatable/equatable.dart';
import 'package:mobile/features/cities/domain/entities/discovery_city_entity.dart';

/// Cidades que a leitora pode escolher para ver grupos e encontros.
class DiscoveryCitiesEntity extends Equatable {
  final String readerCityId;

  /// Por nome: as cidades com grupo ativo mais a da leitora.
  final List<DiscoveryCityEntity> cities;

  const DiscoveryCitiesEntity({
    required this.readerCityId,
    required this.cities,
  });

  /// `null` quando a cidade da leitora não veio na lista.
  DiscoveryCityEntity? get readerCity {
    for (final city in cities) {
      if (city.id == readerCityId) return city;
    }
    return null;
  }

  @override
  List<Object?> get props => [readerCityId, cities];
}
