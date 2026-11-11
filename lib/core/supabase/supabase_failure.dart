import 'package:equatable/equatable.dart';

/// O que deu errado, independente do texto que o backend mandou.
///
/// O `message` das falhas é técnico (e em inglês, na maioria das functions):
/// serve só para log. A tela decide o texto a partir do [kind].
enum SupabaseFailureKind {
  network,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  validation,
  server,
  unknown;

  static SupabaseFailureKind fromStatusCode(int? statusCode) {
    if (statusCode == null) return unknown;
    if (statusCode == 0) return network;
    if (statusCode >= 500) return server;
    return switch (statusCode) {
      401 => unauthorized,
      403 => forbidden,
      404 => notFound,
      409 => conflict,
      400 || 413 || 422 => validation,
      _ => unknown,
    };
  }
}

abstract class SupabaseFailure extends Equatable {
  final String message;
  final String? code;
  final dynamic details;
  final SupabaseFailureKind kind;

  const SupabaseFailure({
    required this.message,
    this.code,
    this.details,
    this.kind = SupabaseFailureKind.unknown,
  });

  @override
  List<Object?> get props => [message, code, details, kind];
}

class UnknownSupabaseFailure extends SupabaseFailure {
  const UnknownSupabaseFailure({
    super.message = 'Erro desconhecido no Supabase',
    super.code,
    super.details,
    super.kind,
  });
}

class AuthSupabaseFailure extends SupabaseFailure {
  /// Código do Supabase Auth (`invalid_credentials`, `email_not_confirmed`...).
  /// O [code] continua sendo o status HTTP.
  final String? errorCode;

  const AuthSupabaseFailure({
    required super.message,
    super.code,
    super.details,
    super.kind,
    this.errorCode,
  });

  @override
  List<Object?> get props => [...super.props, errorCode];
}

class FunctionSupabaseFailure extends SupabaseFailure {
  const FunctionSupabaseFailure({
    required super.message,
    super.code,
    super.details,
    super.kind,
  });
}

class NotFoundSupabaseFailure extends SupabaseFailure {
  const NotFoundSupabaseFailure({
    super.message = 'Registro não encontrado',
    super.code,
    super.details,
    super.kind = SupabaseFailureKind.notFound,
  });
}
