import 'package:mobile/features/group_discovery/data/models/discovery_group_model.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_genre_entity.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_search_page_entity.dart';

/// Resposta da `get-city-groups`: `{ "items": [...], "total", "genres" }`.
class GroupSearchPageModel {
  final List<DiscoveryGroupModel> items;
  final int total;
  final List<GroupGenreEntity> genres;

  const GroupSearchPageModel({
    required this.items,
    required this.total,
    required this.genres,
  });

  factory GroupSearchPageModel.fromJson(Map<String, dynamic> json) {
    final genres = json['genres'] as List<dynamic>? ?? const [];
    return GroupSearchPageModel(
      items: DiscoveryGroupModel.listFromJson(json),
      total: (json['total'] as num?)?.toInt() ?? 0,
      genres: [
        for (final genre in genres.cast<Map<String, dynamic>>())
          GroupGenreEntity(
            id: genre['id'] as String,
            name: genre['name'] as String,
          ),
      ],
    );
  }

  GroupSearchPageEntity toDomain() {
    return GroupSearchPageEntity(
      items: [for (final item in items) item.toDomain()],
      total: total,
      genres: genres,
    );
  }
}
