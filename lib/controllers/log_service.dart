import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class LogService {
  static ILogProvider? _provider;
  static ILogProvider get provider {
    if (_provider == null) {
      throw Exception('Not initialized. Did you call LogProvider.init() first?');
    }
    return _provider!;
  }

  LogService.init({provider}) {
    if (_provider == null) {
      _provider = provider;
    }
  }

  static captureError(error, {stack}) {
    provider.captureError(error, stack: stack);
  }

  static setUser(String userId) {
    provider.setUser(userId);
  }
}

class FirebaseCrashlyticsProvider implements ILogProvider {
  @override
  captureError(error, {stack}) {
    FirebaseCrashlytics.instance.recordError(error, stack);
  }

  @override
  setUser(userId) {
    FirebaseCrashlytics.instance.setUserIdentifier(userId);
  }
}

abstract class ILogProvider {
  captureError(dynamic error, {dynamic stack});
  setUser(String userId);
}