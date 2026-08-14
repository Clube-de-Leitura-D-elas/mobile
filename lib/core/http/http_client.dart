import 'package:mobile/core/http/http_failures.dart';
import 'package:mobile/core/http/http_response.dart';
import 'package:mobile/core/tools/result.dart';

abstract interface class HttpClient {
  Future<Result<HttpResponse, HttpFailure>> get(
    String url, {
    Map<String, dynamic>? queryParameters,
  });
  Future<Result<HttpResponse, HttpFailure>> post(String url, dynamic data);
  Future<Result<HttpResponse, HttpFailure>> put(String url, dynamic data);
  Future<Result<HttpResponse, HttpFailure>> delete(String url, {dynamic data});
}
