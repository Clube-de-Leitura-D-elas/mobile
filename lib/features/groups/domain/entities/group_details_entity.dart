import 'package:equatable/equatable.dart';

class GroupDetailsEntity extends Equatable {
  final String name;
  final List<String> genres;
  final int participantCount;
  final String city;
  final String stateCode;
  final String? coverImageUrl;

  const GroupDetailsEntity({
    required this.name,
    required this.genres,
    required this.participantCount,
    required this.city,
    required this.stateCode,
    this.coverImageUrl,
  });

  @override
  List<Object?> get props => [name, genres, participantCount, city, stateCode, coverImageUrl];
}
