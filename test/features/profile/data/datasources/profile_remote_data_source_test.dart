import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_response.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:mobile/features/profile/data/models/profile_summary_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show HttpMethod;

class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  late MockSupabaseService supabase;
  late ProfileRemoteDataSourceImpl dataSource;

  setUpAll(() => registerFallbackValue(HttpMethod.post));

  setUp(() {
    supabase = MockSupabaseService();
    dataSource = ProfileRemoteDataSourceImpl(supabaseService: supabase);
  });

  void stub(
    Future<Result<SupabaseResponse<ProfileSummaryModel>, SupabaseFailure>>
    Function(Invocation)
    answer,
  ) {
    when(
      () => supabase.invokeFunction<ProfileSummaryModel>(
        functionName: any(named: 'functionName'),
        method: any(named: 'method'),
        decoder: any(named: 'decoder'),
      ),
    ).thenAnswer(answer);
  }

  test('chama a get-my-profile-summary por GET e decodifica', () async {
    stub((invocation) async {
      final decoder =
          invocation.namedArguments[#decoder]
              as ProfileSummaryModel Function(dynamic);
      return Success(
        SupabaseResponse(
          data: decoder({
            'books_read_count': 2,
            'groups': <dynamic>[],
            'reviewed_books': <dynamic>[],
          }),
        ),
      );
    });

    final result = await dataSource.getMyProfileSummary();

    expect(result.unwrap()?.booksReadCount, 2);
    verify(
      () => supabase.invokeFunction<ProfileSummaryModel>(
        functionName: 'get-my-profile-summary',
        method: HttpMethod.get,
        decoder: any(named: 'decoder'),
      ),
    ).called(1);
  });

  test('repassa a falha do Supabase', () async {
    const failure = FunctionSupabaseFailure(
      message: 'x',
      kind: SupabaseFailureKind.network,
    );
    stub((_) async => const Failure(failure));

    final result = await dataSource.getMyProfileSummary();

    expect(
      result,
      const Failure<ProfileSummaryModel?, SupabaseFailure>(failure),
    );
  });
}
