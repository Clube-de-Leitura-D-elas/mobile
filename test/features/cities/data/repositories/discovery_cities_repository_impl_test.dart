import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_response.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/cities/data/models/discovery_cities_model.dart';
import 'package:mobile/features/cities/data/repositories/discovery_cities_repository_impl.dart';
import 'package:mobile/features/cities/domain/entities/cities_failure.dart';
import 'package:mobile/features/cities/domain/entities/discovery_cities_entity.dart';
import 'package:mobile/features/cities/domain/entities/discovery_city_entity.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  late MockSupabaseService service;
  late DiscoveryCitiesRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(HttpMethod.get);
  });

  setUp(() {
    service = MockSupabaseService();
    repository = DiscoveryCitiesRepositoryImpl(supabaseService: service);
  });

  void stub(
    Result<SupabaseResponse<DiscoveryCitiesModel>, SupabaseFailure> result,
  ) {
    when(
      () => service.invokeFunction<DiscoveryCitiesModel>(
        functionName: any(named: 'functionName'),
        method: any(named: 'method'),
        decoder: any(named: 'decoder'),
      ),
    ).thenAnswer((_) async => result);
  }

  test('GETs get-discovery-cities and returns the cities', () async {
    const city = DiscoveryCityEntity(id: 'c-1', name: 'Canoas', uf: 'RS');
    stub(
      const Success(
        SupabaseResponse(
          data: DiscoveryCitiesModel(readerCityId: 'c-1', cities: [city]),
        ),
      ),
    );

    final result = await repository.getCities();

    expect(
      result.unwrap(),
      const DiscoveryCitiesEntity(readerCityId: 'c-1', cities: [city]),
    );
    final call = verify(
      () => service.invokeFunction<DiscoveryCitiesModel>(
        functionName: 'get-discovery-cities',
        method: HttpMethod.get,
        decoder: captureAny(named: 'decoder'),
      ),
    )..called(1);
    final decoder =
        call.captured.single as DiscoveryCitiesModel Function(dynamic);
    expect(
      decoder({
        'reader_city_id': 'c-1',
        'cities': [
          {'id': 'c-1', 'name': 'Canoas', 'uf': 'RS'},
        ],
      }).cities,
      [city],
    );
  });

  test('a backend failure becomes CitiesFailure', () async {
    stub(
      const Failure(
        FunctionSupabaseFailure(
          message: 'boom',
          code: '500',
          kind: SupabaseFailureKind.server,
        ),
      ),
    );

    expect(
      await repository.getCities(),
      const Failure<DiscoveryCitiesEntity, CitiesFailure>(CitiesFailure()),
    );
  });

  test('the decoder rejects a payload without reader_city_id', () async {
    stub(const Success(SupabaseResponse(data: null)));
    await repository.getCities();

    final decoder =
        verify(
              () => service.invokeFunction<DiscoveryCitiesModel>(
                functionName: 'get-discovery-cities',
                method: HttpMethod.get,
                decoder: captureAny(named: 'decoder'),
              ),
            ).captured.single
            as DiscoveryCitiesModel Function(dynamic);
    // O SupabaseService transforma o erro do decoder em Failure.
    expect(
      () => decoder({'reader_city_id': null, 'cities': <dynamic>[]}),
      throwsA(isA<TypeError>()),
    );
  });

  test('an empty body becomes CitiesFailure', () async {
    stub(const Success(SupabaseResponse(data: null)));

    expect(
      await repository.getCities(),
      const Failure<DiscoveryCitiesEntity, CitiesFailure>(CitiesFailure()),
    );
  });
}
