import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/profile/data/models/profile_summary_model.dart';
import 'package:mobile/features/profile/domain/entities/profile_summary_entity.dart';

void main() {
  test('converte a resposta da get-my-profile-summary', () {
    final model = ProfileSummaryModel.fromJson({
      'books_read_count': 5,
      'groups': [
        {'id': 'g-1', 'number': 1, 'photo_url': 'https://example.com/g1.jpg'},
        {'id': 'g-2', 'number': 3, 'photo_url': null},
      ],
      'reviewed_books': [
        {
          'book_id': 'b-1',
          'title': 'Harry Potter e a Pedra Filosofal',
          'cover_url': 'https://example.com/capa.jpg',
          'rating': 4.5,
        },
      ],
    });

    expect(
      model.toDomain(),
      const ProfileSummaryEntity(
        booksReadCount: 5,
        groups: [
          ProfileGroupEntity(
            id: 'g-1',
            number: 1,
            photoUrl: 'https://example.com/g1.jpg',
          ),
          ProfileGroupEntity(id: 'g-2', number: 3),
        ],
        reviewedBooks: [
          ProfileReviewedBookEntity(
            bookId: 'b-1',
            title: 'Harry Potter e a Pedra Filosofal',
            coverUrl: 'https://example.com/capa.jpg',
            rating: 4.5,
          ),
        ],
      ),
    );
  });

  test('aceita um perfil sem livros lidos, grupos ou avaliações', () {
    final model = ProfileSummaryModel.fromJson({
      'books_read_count': 0,
      'groups': <dynamic>[],
      'reviewed_books': <dynamic>[],
    });

    expect(model.toDomain(), const ProfileSummaryEntity(booksReadCount: 0));
  });

  test('usa padrões quando faltam campos opcionais', () {
    final model = ProfileSummaryModel.fromJson({
      'reviewed_books': [
        {'book_id': 'b-1'},
      ],
    });

    final summary = model.toDomain();
    expect(summary.booksReadCount, 0);
    expect(summary.groups, isEmpty);
    expect(
      summary.reviewedBooks.single,
      const ProfileReviewedBookEntity(bookId: 'b-1', title: '', rating: 0),
    );
  });
}
