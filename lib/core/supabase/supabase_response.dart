import 'package:equatable/equatable.dart';

class SupabaseResponse<T> extends Equatable {
  final T? data;
  final int statusCode;
  final String? message;

  const SupabaseResponse({
    this.data,
    this.statusCode = 200,
    this.message,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  @override
  List<Object?> get props => [data, statusCode, message];
}
