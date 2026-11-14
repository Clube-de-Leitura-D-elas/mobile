import 'package:equatable/equatable.dart';
import 'package:mobile/features/group_discovery/domain/entities/discovery_group_entity.dart';

class GroupSearchPageEntity extends Equatable {
  final List<DiscoveryGroupEntity> items;

  /// Grupos que batem com a busca e os filtros, somando todas as páginas.
  final int total;

  const GroupSearchPageEntity({required this.items, required this.total});

  @override
  List<Object?> get props => [items, total];
}
