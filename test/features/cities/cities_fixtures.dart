import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/cities/domain/entities/cities_failure.dart';
import 'package:mobile/features/cities/domain/entities/discovery_cities_entity.dart';
import 'package:mobile/features/cities/domain/entities/discovery_city_entity.dart';
import 'package:mobile/features/cities/domain/repository/discovery_cities_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockDiscoveryCitiesRepository extends Mock
    implements DiscoveryCitiesRepository {}

const portoAlegre = DiscoveryCityEntity(
  id: '20000000-0000-0000-0000-000000000001',
  name: 'Porto Alegre',
  uf: 'RS',
);

const saoPaulo = DiscoveryCityEntity(
  id: '20000000-0000-0000-0000-000000000002',
  name: 'São Paulo',
  uf: 'SP',
);

/// A leitora é de Porto Alegre.
final discoveryCities = DiscoveryCitiesEntity(
  readerCityId: portoAlegre.id,
  cities: const [portoAlegre, saoPaulo],
);

void stubCities(MockDiscoveryCitiesRepository repository) {
  when(repository.getCities).thenAnswer((_) async => Success(discoveryCities));
}

/// Sem a lista de cidades as telas seguem como antes do filtro.
void stubCitiesFailure(MockDiscoveryCitiesRepository repository) {
  when(
    repository.getCities,
  ).thenAnswer((_) async => const Failure(CitiesFailure()));
}
