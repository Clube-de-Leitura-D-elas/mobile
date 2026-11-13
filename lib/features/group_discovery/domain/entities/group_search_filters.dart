import 'package:equatable/equatable.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_genre_entity.dart';

class GroupSearchFilters extends Equatable {
  /// O gênero inteiro, não só o id: o modal mostra o nome mesmo antes de a
  /// lista de gêneros carregar.
  final GroupGenreEntity? genre;
  final int? minParticipants;
  final int? maxParticipants;

  const GroupSearchFilters({
    this.genre,
    this.minParticipants,
    this.maxParticipants,
  });

  static const empty = GroupSearchFilters();

  bool get isEmpty =>
      genre == null && minParticipants == null && maxParticipants == null;

  @override
  List<Object?> get props => [genre, minParticipants, maxParticipants];
}
