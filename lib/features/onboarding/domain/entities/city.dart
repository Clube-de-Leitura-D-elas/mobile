import 'package:equatable/equatable.dart';
import 'package:mobile/features/onboarding/domain/entities/zone.dart';

class City extends Equatable {
  final String id;
  final String name;
  final String uf;
  final List<Zone> zones;

  const City({
    required this.id,
    required this.name,
    required this.uf,
    this.zones = const [],
  });

  @override
  List<Object?> get props => [id, name, uf, zones];
}
