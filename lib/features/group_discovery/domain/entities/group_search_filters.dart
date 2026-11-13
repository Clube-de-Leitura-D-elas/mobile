import 'package:equatable/equatable.dart';

class GroupSearchFilters extends Equatable {
  final String? genreId;
  final int? minParticipants;
  final int? maxParticipants;

  const GroupSearchFilters({
    this.genreId,
    this.minParticipants,
    this.maxParticipants,
  });

  static const empty = GroupSearchFilters();

  bool get isEmpty =>
      genreId == null && minParticipants == null && maxParticipants == null;

  @override
  List<Object?> get props => [genreId, minParticipants, maxParticipants];
}
