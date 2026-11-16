import 'package:equatable/equatable.dart';

class BookRecommendationGroup extends Equatable {
  const BookRecommendationGroup({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.alreadyRecommended,
  });

  final String id;
  final String name;
  final String? photoUrl;
  final bool alreadyRecommended;

  @override
  List<Object?> get props => [id, name, photoUrl, alreadyRecommended];
}
