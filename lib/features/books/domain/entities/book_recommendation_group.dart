import 'package:equatable/equatable.dart';

class BookRecommendationGroup extends Equatable {
  const BookRecommendationGroup({
    required this.id,
    this.number,
    required this.name,
    this.photoUrl,
    required this.alreadyRecommended,
  });

  final String id;
  final int? number;
  final String name;
  final String? photoUrl;
  final bool alreadyRecommended;

  BookRecommendationGroup copyWith({bool? alreadyRecommended}) {
    return BookRecommendationGroup(
      id: id,
      number: number,
      name: name,
      photoUrl: photoUrl,
      alreadyRecommended: alreadyRecommended ?? this.alreadyRecommended,
    );
  }

  @override
  List<Object?> get props => [id, number, name, photoUrl, alreadyRecommended];
}
