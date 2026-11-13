import 'package:equatable/equatable.dart';
import 'package:mobile/features/group_discovery/domain/entities/discovery_group_entity.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_genre_entity.dart';

class GroupSearchPageEntity extends Equatable {
  final List<DiscoveryGroupEntity> items;

  /// Grupos que batem com a busca e os filtros, somando todas as páginas.
  final int total;

  /// Gêneros dos grupos da cidade, para o filtro; não dependem da busca.
  final List<GroupGenreEntity> genres;

  const GroupSearchPageEntity({
    required this.items,
    required this.total,
    required this.genres,
  });

  @override
  List<Object?> get props => [items, total, genres];
}
