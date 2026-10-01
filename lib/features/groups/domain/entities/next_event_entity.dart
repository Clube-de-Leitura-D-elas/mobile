import 'package:equatable/equatable.dart';

/// Representa o próximo encontro agendado de um grupo.
///
/// A data é validada e convertida do ISO 8601 pela camada de dados.
class NextEventEntity extends Equatable {
  const NextEventEntity({
    required this.location,
    required this.date,
    required this.hostName,
  });

  final String location;

  final DateTime date;

  final String hostName;

  @override
  List<Object?> get props => [location, date, hostName];
}
