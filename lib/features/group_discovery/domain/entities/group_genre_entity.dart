import 'package:equatable/equatable.dart';

class GroupGenreEntity extends Equatable {
  final String id;
  final String name;

  const GroupGenreEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
