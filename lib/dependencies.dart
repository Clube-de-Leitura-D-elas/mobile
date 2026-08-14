import 'package:mobile/core/environment/environment.dart';
import 'package:mobile/core/http/http_dependencies.dart';

class DependenciesContainer {
  DependenciesContainer() {
    ApiDependencies(baseUrl: Environment.baseUrl);
  }
}
