import 'package:equatable/equatable.dart';

class DiscoveryCityEntity extends Equatable {
  final String id;
  final String name;
  final String uf;

  const DiscoveryCityEntity({
    required this.id,
    required this.name,
    required this.uf,
  });

  @override
  List<Object?> get props => [id, name, uf];
}
