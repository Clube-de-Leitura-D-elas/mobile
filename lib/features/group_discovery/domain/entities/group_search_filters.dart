import 'package:equatable/equatable.dart';
import 'package:mobile/features/cities/domain/entities/discovery_city_entity.dart';

class GroupSearchFilters extends Equatable {
  /// `null` é "Todas as cidades". A cidade inteira, não só o id: o modal
  /// mostra o nome dela.
  final DiscoveryCityEntity? city;
  final int? minParticipants;
  final int? maxParticipants;

  const GroupSearchFilters({
    this.city,
    this.minParticipants,
    this.maxParticipants,
  });

  static const empty = GroupSearchFilters();

  bool get isEmpty =>
      city == null && minParticipants == null && maxParticipants == null;

  @override
  List<Object?> get props => [city, minParticipants, maxParticipants];
}
