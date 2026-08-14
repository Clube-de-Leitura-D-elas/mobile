import 'package:get_it/get_it.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  final GetIt _getIt;

  ServiceLocator._internal() : _getIt = GetIt.instance;

  static ServiceLocator get instance => _instance;

  bool get allowReassignment => _getIt.allowReassignment;
  set allowReassignment(bool value) => _getIt.allowReassignment = value;

  void registerSingleton<T extends Object>(T instance, {String? instanceName}) {
    _getIt.registerSingleton<T>(instance, instanceName: instanceName);
  }

  void registerFactory<T extends Object>(
    T Function() factory, {
    String? instanceName,
  }) {
    _getIt.registerFactory<T>(factory, instanceName: instanceName);
  }

  void registerFactoryParam<T extends Object, P1, P2>(
    T Function(P1 param1, P2 param2) factory, {
    String? instanceName,
  }) {
    _getIt.registerFactoryParam<T, P1, P2>(factory, instanceName: instanceName);
  }

  void registerFactoryParam1<T extends Object, P1>(
    T Function(P1 param1) factory, {
    String? instanceName,
  }) {
    _getIt.registerFactoryParam<T, P1, void>(
      (p1, _) => factory(p1),
      instanceName: instanceName,
    );
  }

  void registerLazySingleton<T extends Object>(
    T Function() factory, {
    String? instanceName,
  }) {
    _getIt.registerLazySingleton<T>(factory, instanceName: instanceName);
  }

  T get<T extends Object>({String? instanceName}) {
    return _getIt.get<T>(instanceName: instanceName);
  }

  T getWithParams<T extends Object, P1, P2>({
    required P1 param1,
    required P2 param2,
    String? instanceName,
  }) {
    return _getIt.get<T>(
      param1: param1,
      param2: param2,
      instanceName: instanceName,
    );
  }

  T getWithParam<T extends Object, P1>({
    required P1 param1,
    String? instanceName,
  }) {
    return _getIt.get<T>(param1: param1, instanceName: instanceName);
  }

  T call<T extends Object>({String? instanceName}) {
    return _getIt.get<T>(instanceName: instanceName);
  }

  bool isRegistered<T extends Object>({String? instanceName}) {
    return _getIt.isRegistered<T>(instanceName: instanceName);
  }

  void unregister<T extends Object>({String? instanceName}) {
    _getIt.unregister<T>(instanceName: instanceName);
  }

  Future<void> reset() async {
    await _getIt.reset();
  }
}

final serviceLocator = ServiceLocator.instance;
