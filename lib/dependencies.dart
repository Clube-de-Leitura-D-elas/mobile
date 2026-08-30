import 'package:mobile/core/environment/environment.dart';
import 'package:mobile/core/http/http_dependencies.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DependenciesContainer {
  DependenciesContainer() {
    ApiDependencies(baseUrl: Environment.baseUrl);

    serviceLocator.registerSingleton<SupabaseClient>(
      Supabase.instance.client,
      instanceName: 'SupabaseClient',
    );
  }
}
