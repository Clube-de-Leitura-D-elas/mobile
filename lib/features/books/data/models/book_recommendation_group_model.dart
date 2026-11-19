import 'package:mobile/features/books/domain/entities/book_recommendation_group.dart';

class BookRecommendationGroupModel extends BookRecommendationGroup {
  const BookRecommendationGroupModel({
    required super.id,
    super.number,
    required super.name,
    super.photoUrl,
    required super.alreadyRecommended,
  });

  factory BookRecommendationGroupModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Invalid recommendation group.');
    }

    final id = json['group_id'];
    final number = json['number'];
    final name = json['name'];
    final photoUrl = json['photo_url'];
    final alreadyRecommended = json['already_recommended'];
    if (id is! String ||
        (number != null && number is! int) ||
        name is! String ||
        (photoUrl != null && photoUrl is! String) ||
        alreadyRecommended is! bool) {
      throw const FormatException('Invalid recommendation group.');
    }

    return BookRecommendationGroupModel(
      id: id,
      number: number as int?,
      name: name,
      photoUrl: photoUrl as String?,
      alreadyRecommended: alreadyRecommended,
    );
  }

  static List<BookRecommendationGroupModel> listFromJson(dynamic json) {
    if (json is! Map<String, dynamic> || json['items'] is! List) {
      throw const FormatException('Invalid recommendation groups response.');
    }
    return (json['items'] as List)
        .map(BookRecommendationGroupModel.fromJson)
        .toList();
  }

  BookRecommendationGroup toDomain() => BookRecommendationGroup(
    id: id,
    number: number,
    name: name,
    photoUrl: photoUrl,
    alreadyRecommended: alreadyRecommended,
  );
}
