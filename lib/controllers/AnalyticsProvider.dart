import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:fyx/controllers/log_service.dart';

/// Analytics facade. Fans every call out to all registered [IAnalyticsProvider]s,
/// so call sites stay the same when a destination is added or removed.
class AnalyticsProvider {
  static final AnalyticsProvider _instance = AnalyticsProvider._init();
  static List<IAnalyticsProvider>? _providers;

  factory AnalyticsProvider() {
    if (_providers == null) {
      throw Exception('Analytics providers must be set! Did you call AnalyticsProvider.init() first?');
    }
    return _instance;
  }

  AnalyticsProvider._init();

  static void init(List<IAnalyticsProvider> providers) => _providers = providers;

  static bool get isInitialized => _providers != null;

  Map<String, Object>? _lastUserProperties;

  /// The nickname never leaves the device; every destination gets its [fingerprint].
  Future<void> setUser(String nickname) => _each((provider) => provider.setUser(fingerprint(nickname)));

  /// Stable, non-reversible id derived from the nickname (case-insensitive on Nyx).
  static String fingerprint(String nickname) => sha256.convert(utf8.encode('fyx:${nickname.toLowerCase()}')).toString();

  Future<void> setScreen(String screenName, String screenClassOverride) =>
      _each((provider) => provider.setScreen(screenName, screenClassOverride));

  Future<void> setUserProperty(String name, Object value) => setUserProperties({name: value});

  /// Skipped when nothing changed since the last call.
  Future<void> setUserProperties(Map<String, Object> properties) {
    if (mapEquals(_lastUserProperties, properties)) return Future.value();
    _lastUserProperties = Map.of(properties);
    return _each((provider) => provider.setUserProperties(properties));
  }

  Future<void> logTutorialBegin() => logEvent('tutorial_begin');

  Future<void> logTutorialComplete() => logEvent('tutorial_complete');

  Future<void> logEvent(String name, {Map<String, Object>? parameters}) => _each((provider) => provider.logEvent(name, parameters: parameters));

  /// Forgets the user, e.g. on logout.
  Future<void> reset() {
    _lastUserProperties = null;
    return _each((provider) => provider.reset());
  }

  // One failing destination must not stop the others.
  Future<void> _each(Future<void> Function(IAnalyticsProvider provider) call) async {
    await Future.wait(_providers!.map((provider) async {
      try {
        await call(provider);
      } catch (error, stack) {
        LogService.captureError(error, stack: stack);
      }
    }));
  }
}

abstract class IAnalyticsProvider {
  /// [userId] is already a fingerprint, never the nickname.
  Future<void> setUser(String userId);

  Future<void> setScreen(String screenName, String screenClass);

  Future<void> setUserProperties(Map<String, Object> properties);

  Future<void> logEvent(String name, {Map<String, Object>? parameters});

  Future<void> reset();
}

class FirebaseAnalyticsProvider implements IAnalyticsProvider {
  final FirebaseAnalytics _analytics;

  FirebaseAnalyticsProvider(this._analytics);

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
