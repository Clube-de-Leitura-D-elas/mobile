import 'package:equatable/equatable.dart';

class Zone extends Equatable {
  final String id;
  final String name;

  const Zone({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
