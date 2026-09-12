import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';

class SampleService {
  final String name;
  SampleService([this.name = 'default']);
}

class ParamService {
  final String p1;
  final int p2;
  ParamService(this.p1, this.p2);
}

class SingleParamService {
  final String p1;
  SingleParamService(this.p1);
}

void main() {
  setUp(() async {
    serviceLocator.allowReassignment = true;
    await serviceLocator.reset();
  });

  tearDown(() async {
    serviceLocator.allowReassignment = true;
    await serviceLocator.reset();
  });

  group('ServiceLocator', () {
    test('allowReassignment getter and setter works', () {
      serviceLocator.allowReassignment = true;
      expect(serviceLocator.allowReassignment, isTrue);
      serviceLocator.allowReassignment = false;
      expect(serviceLocator.allowReassignment, isFalse);
    });

    test('registerSingleton and get/call work correctly', () {
      final sample = SampleService('test');
      serviceLocator.registerSingleton<SampleService>(sample);

      expect(serviceLocator.isRegistered<SampleService>(), isTrue);
      expect(serviceLocator.get<SampleService>(), equals(sample));
      expect(serviceLocator<SampleService>(), equals(sample));
    });

    test('registerFactory creates new instance each call', () {
      serviceLocator.registerFactory<SampleService>(() => SampleService('factory'));

      final s1 = serviceLocator.get<SampleService>();
      final s2 = serviceLocator.get<SampleService>();

      expect(s1.name, 'factory');
      expect(s2.name, 'factory');
      expect(identical(s1, s2), isFalse);
    });

    test('registerLazySingleton creates instance lazily', () {
      int count = 0;
      serviceLocator.registerLazySingleton<SampleService>(() {
        count++;
        return SampleService('lazy');
      });

      expect(count, 0);
      final s1 = serviceLocator.get<SampleService>();
      expect(count, 1);
      final s2 = serviceLocator.get<SampleService>();
      expect(count, 1);
      expect(identical(s1, s2), isTrue);
    });

    test('registerFactoryParam and getWithParams work', () {
      serviceLocator.registerFactoryParam<ParamService, String, int>(
        (p1, p2) => ParamService(p1, p2),
      );

      final paramService = serviceLocator.getWithParams<ParamService, String, int>(
        param1: 'hello',
        param2: 42,
      );

      expect(paramService.p1, 'hello');
      expect(paramService.p2, 42);
    });

    test('registerFactoryParam1 and getWithParam work', () {
      serviceLocator.registerFactoryParam1<SingleParamService, String>(
        (p1) => SingleParamService(p1),
      );

      final singleParamService =
          serviceLocator.getWithParam<SingleParamService, String>(
        param1: 'world',
      );

      expect(singleParamService.p1, 'world');
    });

    test('unregister removes registration', () {
      serviceLocator.registerSingleton<SampleService>(SampleService());
      expect(serviceLocator.isRegistered<SampleService>(), isTrue);

      serviceLocator.unregister<SampleService>();
      expect(serviceLocator.isRegistered<SampleService>(), isFalse);
    });
  });
}
