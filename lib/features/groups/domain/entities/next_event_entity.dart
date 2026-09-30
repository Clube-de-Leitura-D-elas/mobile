import 'package:equatable/equatable.dart';

/// Representa o próximo encontro agendado de um grupo.
///
/// A data é armazenada como string ISO 8601 (conforme entregue pelo Supabase).
/// A conversão para fuso local é responsabilidade da camada de apresentação.
class NextEventEntity extends Equatable {
  const NextEventEntity({
    required this.location,
    required this.date,
    required this.hostName,
  });

  final String location;

  /// Data/hora do encontro em formato ISO 8601 (ex: "2026-09-15T21:30:00Z").
  final String date;

  final String hostName;

  @override
  List<Object?> get props => [location, date, hostName];
}
