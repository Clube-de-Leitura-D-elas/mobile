import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/books/data/models/rated_book_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class RatedBooksRemoteDataSource {
  Future<List<RatedBookModel>> getRatedBooks({
    required int page,
    required int limit,
  });
}

class RatedBooksRemoteDataSourceImpl implements RatedBooksRemoteDataSource {
  final SupabaseService supabaseService;

  RatedBooksRemoteDataSourceImpl({required this.supabaseService});

  @override
  Future<List<RatedBookModel>> getRatedBooks({
    required int page,
    required int limit,
  }) async {
    final result = await supabaseService.invokeFunction<List<RatedBookModel>>(
      functionName: 'get-rated-books',
      method: HttpMethod.get,
      queryParameters: {
        'page': '$page',
        'limit': '$limit',
      },
      decoder: RatedBookModel.listFromJson,
    );

    return switch (result) {
      Success(:final data) => data.data ?? const [],
      Failure(:final failure) => throw failure,
    };
  }
}
