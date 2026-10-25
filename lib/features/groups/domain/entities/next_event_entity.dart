import 'package:equatable/equatable.dart';

/// Representa o próximo encontro agendado de um grupo.
///
/// A data é validada e convertida do ISO 8601 pela camada de dados.
class NextEventEntity extends Equatable {
  const NextEventEntity({
    required this.location,
    required this.date,
    required this.hostName,
    this.bookTitle,
    this.bookCoverUrl,
    this.id,
  });

  /// Identificador do encontro; usado para abrir os detalhes dele.
  final String? id;

  final String location;

  final DateTime date;

  final String hostName;

  final String? bookTitle;

  final String? bookCoverUrl;

  @override
  List<Object?> get props => [
    id,
    location,
    date,
    hostName,
    bookTitle,
    bookCoverUrl,
  ];
}
