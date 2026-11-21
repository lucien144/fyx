import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:fyx/shared/services/analytics/analytics_service.dart';

class FirebaseAnalyticsDestination implements IAnalyticsDestination {
  final FirebaseAnalytics _analytics;

  FirebaseAnalyticsDestination(this._analytics);

  @override
  Future<void> setUser(String userId) => _analytics.setUserId(id: userId);

  @override
  Future<void> setScreen(String screenName, String screenClass) =>
      _analytics.logScreenView(screenName: screenName, screenClass: screenClass);

  @override
  Future<void> setUserProperties(Map<String, Object> properties) async {
    for (final entry in properties.entries) {
      await _analytics.setUserProperty(name: entry.key, value: entry.value.toString());
    }
  }

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) => _analytics.logEvent(name: name, parameters: parameters);

  @override
  Future<void> reset() => _analytics.setUserId(id: null);
}
