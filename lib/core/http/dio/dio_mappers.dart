import 'package:dio/dio.dart';
import 'package:mobile/core/http/http_failures.dart';

HttpFailure mapDioExceptionToFailure(DioException e) {
  return switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => RequestTimeoutFailure(
      extractErrorMessage(e.response?.data, e.message ?? 'Request timeout'),
    ),

    DioExceptionType.badResponse when e.response != null =>
      httpFailureFromStatusCode(
        e.response!.statusCode ?? 0,
        extractErrorMessage(e.response!.data, e.message ?? 'Bad response'),
      ),

    DioExceptionType.cancel => const UnknownFailure('Request cancelled'),

    DioExceptionType.badCertificate => UnknownFailure(
      e.message ?? 'Bad certificate',
    ),

    DioExceptionType.connectionError => UnknownFailure(
      e.message ?? 'Connection error',
    ),

    DioExceptionType.unknown || _ => UnknownFailure(e.message ?? e.toString()),
  };
}

String extractErrorMessage(dynamic data, [String? fallback]) {
  if (data is String && data.isNotEmpty) {
    return data;
  }
  if (data is Map) {
    final message = data['message'] ?? data['error'] ?? data['detail'];
    if (message != null && message.toString().isNotEmpty) {
      return message.toString();
    }
  }
  return fallback ?? 'Unknown error';
}
