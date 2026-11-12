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
  final bool enableMockFallback;

  RatedBooksRemoteDataSourceImpl({
    required this.supabaseService,
    this.enableMockFallback = true,
  });

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
      Failure() when enableMockFallback =>
        _getMockRatedBooks(page: page, limit: limit),
      Failure(:final failure) => throw Exception(failure.message),
    };
  }

  List<RatedBookModel> _getMockRatedBooks({
    required int page,
    required int limit,
  }) {
    final allMocks = [
      const RatedBookModel(
        id: 'rated-1',
        bookId: 'book-1',
        title: 'Harry Potter e a Pedra Filosofal',
        author: 'J. K. Rowling',
        coverUrl:
            'https://images.unsplash.com/photo-1544947950-fa07a98d237f?auto=format&fit=crop&q=80&w=400',
        rating: 4.5,
        comment:
            'Uma leitura nostálgica e maravilhosa. O universo construído é impecável.',
      ),
      const RatedBookModel(
        id: 'rated-2',
        bookId: 'book-2',
        title: 'Harry Potter e a Câmara Secreta',
        author: 'J. K. Rowling',
        coverUrl:
            'https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&q=80&w=400',
        rating: 4.0,
        comment:
            'Gostei muito do mistério envolvendo o basilisco e o diário de Tom Riddle.',
      ),
      const RatedBookModel(
        id: 'rated-3',
        bookId: 'book-3',
        title: 'Orgulho e Preconceito',
        author: 'Jane Austen',
        coverUrl:
            'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?auto=format&fit=crop&q=80&w=400',
        rating: 5.0,
        comment:
            'Elizabeth Bennet e Mr. Darcy são perfeitos. Diálogos brilhantes e atemporais.',
      ),
      const RatedBookModel(
        id: 'rated-4',
        bookId: 'book-4',
        title: 'A Redoma de Vidro',
        author: 'Sylvia Plath',
        coverUrl:
            'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?auto=format&fit=crop&q=80&w=400',
        rating: 4.5,
        comment:
            'Uma escrita visceral e necessária sobre a saúde mental e as pressões da sociedade.',
      ),
      const RatedBookModel(
        id: 'rated-5',
        bookId: 'book-5',
        title: 'Pequenos Incêndios por Toda Parte',
        author: 'Celeste Ng',
        coverUrl:
            'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?auto=format&fit=crop&q=80&w=400',
        rating: 4.0,
        comment: 'Personagens cheios de camadas e dilemas morais fascinantes.',
      ),
      const RatedBookModel(
        id: 'rated-6',
        bookId: 'book-6',
        title: 'Circe',
        author: 'Madeline Miller',
        coverUrl:
            'https://images.unsplash.com/photo-1476275466078-4007374efbbe?auto=format&fit=crop&q=80&w=400',
        rating: 5.0,
        comment:
            'Releitura mitológica incrível! A jornada de autodescoberta de Circe é emocionante.',
      ),
      const RatedBookModel(
        id: 'rated-7',
        bookId: 'book-7',
        title: 'Tudo É Rio',
        author: 'Carla Madeira',
        coverUrl:
            'https://images.unsplash.com/photo-1516979187457-637abb4f9353?auto=format&fit=crop&q=80&w=400',
        rating: 5.0,
        comment:
            'Prosa poética arrebatadora. Não consegui largar até terminar.',
      ),
      const RatedBookModel(
        id: 'rated-8',
        bookId: 'book-8',
        title: 'O Conto da Aia',
        author: 'Margaret Atwood',
        coverUrl:
            'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?auto=format&fit=crop&q=80&w=400',
        rating: 4.5,
        comment: 'Distopia assustadoramente atual e reflexiva.',
      ),
      const RatedBookModel(
        id: 'rated-9',
        bookId: 'book-9',
        title: 'Torto Arado',
        author: 'Itamar Vieira Junior',
        coverUrl:
            'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?auto=format&fit=crop&q=80&w=400',
        rating: 5.0,
        comment:
            'Uma obra-prima da literatura brasileira contemporânea. Bibiana e Belonísia inesquecíveis.',
      ),
      const RatedBookModel(
        id: 'rated-10',
        bookId: 'book-10',
        title: 'A Vegetariana',
        author: 'Han Kang',
        coverUrl:
            'https://images.unsplash.com/photo-1491841573634-28140fc7ced7?auto=format&fit=crop&q=80&w=400',
        rating: 3.5,
        comment:
            'Livro perturbador e impactante. Vale a leitura pela originalidade.',
      ),
      const RatedBookModel(
        id: 'rated-11',
        bookId: 'book-11',
        title: 'Americanah',
        author: 'Chimamanda Ngozi Adichie',
        coverUrl:
            'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&q=80&w=400',
        rating: 4.5,
        comment:
            'Reflexões profundas sobre raça, identidade e imigração com humor e sensibilidade.',
      ),
      const RatedBookModel(
        id: 'rated-12',
        bookId: 'book-12',
        title: 'Quarto de Despejo',
        author: 'Carolina Maria de Jesus',
        coverUrl:
            'https://images.unsplash.com/photo-1519682337058-a94d519337bc?auto=format&fit=crop&q=80&w=400',
        rating: 5.0,
        comment: 'Relato real, cru e potente que todas deveriam ler.',
      ),
    ];

    final startIndex = (page - 1) * limit;
    if (startIndex >= allMocks.length) {
      return const [];
    }
    final endIndex = (startIndex + limit).clamp(0, allMocks.length);
    return allMocks.sublist(startIndex, endIndex);
  }
}
