import 'package:equatable/equatable.dart';

abstract class SupabaseFailure extends Equatable {
  final String message;
  final String? code;
  final dynamic details;

  const SupabaseFailure({
    required this.message,
    this.code,
    this.details,
  });

  @override
  List<Object?> get props => [message, code, details];
}

class UnknownSupabaseFailure extends SupabaseFailure {
  const UnknownSupabaseFailure({
    super.message = 'Erro desconhecido no Supabase',
    super.code,
    super.details,
  });
}

class AuthSupabaseFailure extends SupabaseFailure {
  const AuthSupabaseFailure({
    required super.message,
    super.code,
    super.details,
  });
}

class FunctionSupabaseFailure extends SupabaseFailure {
  const FunctionSupabaseFailure({
    required super.message,
    super.code,
    super.details,
  });
}

class NotFoundSupabaseFailure extends SupabaseFailure {
  const NotFoundSupabaseFailure({
    super.message = 'Registro não encontrado',
    super.code,
    super.details,
  });
}
