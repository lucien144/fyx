import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsProvider {
  static final AnalyticsProvider _instance = AnalyticsProvider._init();
  static FirebaseAnalytics? provider;

  factory AnalyticsProvider() {
    if (provider == null) {
      throw Exception('Analytics provider must be set!');
    }
    return _instance;
  }

  AnalyticsProvider._init();

  Future<void> setUser(String userId) async {
    await provider!.setUserId(userId);
  }

  Future<void> setScreen(String screenName, String screenClassOverride) async {
    await provider!.setCurrentScreen(
      screenName: screenName,
      screenClassOverride: screenClassOverride,
    );
  }

  Future<void> setUserProperty(String name, String value) async {
    await provider!.setUserProperty(name: name, value: value);
  }

  Future<void> logTutorialBegin() async {
    await provider!.logTutorialBegin();
  }

  Future<void> logTutorialComplete() async {
    await provider!.logTutorialComplete();
  }

  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    await provider!.logEvent(
      name: name,
      parameters: parameters
    );
  }
}
