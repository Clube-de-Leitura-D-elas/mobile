import 'package:equatable/equatable.dart';

class HttpResponse extends Equatable {
  final int statusCode;
  final dynamic data;

  const HttpResponse({required this.statusCode, required this.data});

  @override
  List<Object?> get props => [statusCode, data];
}
