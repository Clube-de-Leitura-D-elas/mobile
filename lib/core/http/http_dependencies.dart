import 'package:dio/dio.dart';
import 'package:mobile/core/http/dio/dio_adapter.dart';
import 'package:mobile/core/http/http_client.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';

class ApiDependencies {
  final String baseUrl;
  final List<InterceptorsWrapper>? interceptors;

  ApiDependencies({required this.baseUrl, this.interceptors}) {
    final baseOptions = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
    );

    final dio = Dio(baseOptions);

    final interceptorsList = interceptors;

    if (interceptorsList != null) {
      for (final interceptor in interceptorsList) {
        dio.interceptors.add(interceptor);
      }
    }

    serviceLocator.registerSingleton<HttpClient>(
      DioAdapter(dio: dio),
      instanceName: 'DefaultAPI',
    );
  }
}
