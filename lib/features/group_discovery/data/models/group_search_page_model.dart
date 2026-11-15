import 'package:mobile/features/group_discovery/data/models/discovery_group_model.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_search_page_entity.dart';

/// Resposta da `get-city-groups`: `{ "items": [...], "total" }`.
class GroupSearchPageModel {
  final List<DiscoveryGroupModel> items;
  final int total;

  const GroupSearchPageModel({required this.items, required this.total});

  factory GroupSearchPageModel.fromJson(Map<String, dynamic> json) {
    return GroupSearchPageModel(
      items: DiscoveryGroupModel.listFromJson(json),
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }

  GroupSearchPageEntity toDomain() {
    return GroupSearchPageEntity(
      items: [for (final item in items) item.toDomain()],
      total: total,
    );
  }
}
