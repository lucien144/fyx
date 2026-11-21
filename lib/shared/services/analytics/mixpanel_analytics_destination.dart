import 'package:fyx/shared/services/analytics/analytics_service.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

/// Sends analytics to Mixpanel (EU data residency).
///
/// Settings are both People properties and super properties, so every event
/// can be segmented by them.
class MixpanelAnalyticsDestination implements IAnalyticsDestination {
  static const euServerUrl = 'https://api-eu.mixpanel.com';
  static const screenViewEvent = 'Screen View';

  final Mixpanel _mixpanel;

  MixpanelAnalyticsDestination._(this._mixpanel);

  static Future<MixpanelAnalyticsDestination> create(String token) async {
    final mixpanel = await Mixpanel.init(token, trackAutomaticEvents: true, serverURL: euServerUrl);
    return MixpanelAnalyticsDestination._(mixpanel);
  }

  @override
  Future<void> setUser(String userId) => _mixpanel.identify(userId);

  @override
  Future<void> setScreen(String screenName, String screenClass) =>
      _mixpanel.track(screenViewEvent, properties: {'screen': screenName, 'screenClass': screenClass});

  @override
  Future<void> setUserProperties(Map<String, Object> properties) async {
    final people = _mixpanel.getPeople();
    properties.forEach(people.set);
    await _mixpanel.registerSuperProperties(properties);
  }

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) => _mixpanel.track(name, properties: parameters);

  @override
  Future<void> reset() => _mixpanel.reset();
}
