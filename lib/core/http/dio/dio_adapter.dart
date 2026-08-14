import 'package:dio/dio.dart';
import 'package:mobile/core/http/dio/dio_mappers.dart';
import 'package:mobile/core/http/http_client.dart';
import 'package:mobile/core/http/http_failures.dart';
import 'package:mobile/core/http/http_response.dart';
import 'package:mobile/core/tools/result.dart';

class DioAdapter implements HttpClient {
  final Dio dio;

  DioAdapter({required this.dio});

  @override
  Future<Result<HttpResponse, HttpFailure>> get(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) => _safeRequest(() => dio.get(url, queryParameters: queryParameters));

  @override
  Future<Result<HttpResponse, HttpFailure>> post(String url, dynamic data) =>
      _safeRequest(() => dio.post(url, data: data));

  @override
  Future<Result<HttpResponse, HttpFailure>> put(String url, dynamic data) =>
      _safeRequest(() => dio.put(url, data: data));

  @override
  Future<Result<HttpResponse, HttpFailure>> delete(
    String url, {
    dynamic data,
  }) => _safeRequest(() => dio.delete(url, data: data));

  Future<Result<HttpResponse, HttpFailure>> _safeRequest(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final response = await request();
      final statusCode = response.statusCode ?? 0;

      if (statusCode >= 400) {
        final message = extractErrorMessage(response.data);
        return Failure(httpFailureFromStatusCode(statusCode, message));
      }

      return Success(HttpResponse(statusCode: statusCode, data: response.data));
    } on DioException catch (e) {
      return Failure(mapDioExceptionToFailure(e));
    } catch (e) {
      return Failure(UnknownFailure(e.toString()));
    }
  }
}
