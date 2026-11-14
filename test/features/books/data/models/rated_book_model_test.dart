import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/books/data/models/rated_book_model.dart';
import 'package:mobile/features/books/domain/entities/rated_book.dart';

void main() {
  group('RatedBookModel', () {
    const jsonMap = {
      'id': 'rated-1',
      'book_id': 'book-1',
      'title': 'Harry Potter e a Pedra Filosofal',
      'author': 'J. K. Rowling',
      'cover_url': 'https://example.com/cover.jpg',
      'rating': 4.5,
      'comment': 'Livro incrível!',
    };

    test('fromJson parses correctly', () {
      final model = RatedBookModel.fromJson(jsonMap);

      expect(model.id, 'rated-1');
      expect(model.bookId, 'book-1');
      expect(model.title, 'Harry Potter e a Pedra Filosofal');
      expect(model.author, 'J. K. Rowling');
      expect(model.coverUrl, 'https://example.com/cover.jpg');
      expect(model.rating, 4.5);
      expect(model.comment, 'Livro incrível!');
    });

    test('toJson serializes correctly', () {
      final model = RatedBookModel.fromJson(jsonMap);
      final json = model.toJson();

      expect(json['id'], 'rated-1');
      expect(json['book_id'], 'book-1');
      expect(json['title'], 'Harry Potter e a Pedra Filosofal');
      expect(json['author'], 'J. K. Rowling');
      expect(json['cover_url'], 'https://example.com/cover.jpg');
      expect(json['rating'], 4.5);
      expect(json['comment'], 'Livro incrível!');
    });

    test('toDomain maps to RatedBook entity', () {
      final model = RatedBookModel.fromJson(jsonMap);
      final entity = model.toDomain();

      expect(entity, isA<RatedBook>());
      expect(entity.id, 'rated-1');
      expect(entity.bookId, 'book-1');
      expect(entity.title, 'Harry Potter e a Pedra Filosofal');
      expect(entity.author, 'J. K. Rowling');
      expect(entity.coverUrl, 'https://example.com/cover.jpg');
      expect(entity.rating, 4.5);
      expect(entity.comment, 'Livro incrível!');
    });

    test('listFromJson parses list or map with books key', () {
      final list = RatedBookModel.listFromJson([jsonMap]);
      expect(list.length, 1);
      expect(list.first.title, 'Harry Potter e a Pedra Filosofal');

      final wrappedList = RatedBookModel.listFromJson({'books': [jsonMap]});
      expect(wrappedList.length, 1);
      expect(wrappedList.first.title, 'Harry Potter e a Pedra Filosofal');

      expect(RatedBookModel.listFromJson(null), isEmpty);
    });
  });
}
