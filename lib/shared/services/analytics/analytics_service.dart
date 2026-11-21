import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:fyx/controllers/log_service.dart';

/// Analytics entry point. Fans every call out to all [IAnalyticsDestination]s,
/// so call sites stay the same when a destination is added or removed.
///
/// Registered in get_it by `registerAnalytics()` during `FyxApp.init()`.
class AnalyticsService {
  final List<IAnalyticsDestination> _destinations;
  final void Function(Object error, StackTrace stack) _logError;

  AnalyticsService(this._destinations, {void Function(Object error, StackTrace stack)? logError})
      : _logError = logError ?? _captureError;

  static void _captureError(Object error, StackTrace stack) => LogService.captureError(error, stack: stack);

  Map<String, Object>? _lastUserProperties;

  /// Stable, non-reversible id derived from the nickname (case-insensitive on Nyx).
  static String fingerprint(String nickname) => sha256.convert(utf8.encode('fyx:${nickname.toLowerCase()}')).toString();

  /// The nickname never leaves the device; every destination gets its [fingerprint].
  Future<void> setUser(String nickname) => _each((destination) => destination.setUser(fingerprint(nickname)));

  Future<void> setScreen(String screenName, String screenClass) => _each((destination) => destination.setScreen(screenName, screenClass));

  /// Skipped when nothing changed since the last call.
  Future<void> setUserProperties(Map<String, Object> properties) {
    if (mapEquals(_lastUserProperties, properties)) return Future.value();
    _lastUserProperties = Map.of(properties);
    return _each((destination) => destination.setUserProperties(properties));
  }

  Future<void> logTutorialBegin() => logEvent('tutorial_begin');

  Future<void> logTutorialComplete() => logEvent('tutorial_complete');

  Future<void> logEvent(String name, {Map<String, Object>? parameters}) =>
      _each((destination) => destination.logEvent(name, parameters: parameters));

  /// Forgets the user, e.g. on logout.
  Future<void> reset() {
    _lastUserProperties = null;
    return _each((destination) => destination.reset());
  }

  // One failing destination must not stop the others.
  Future<void> _each(Future<void> Function(IAnalyticsDestination destination) call) async {
    await Future.wait(_destinations.map((destination) async {
      try {
        await call(destination);
      } catch (error, stack) {
        _logError(error, stack);
      }
    }));
  }
}

/// One analytics backend (Firebase, Mixpanel, ...).
abstract class IAnalyticsDestination {
  /// [userId] is already a fingerprint, never the nickname.
  Future<void> setUser(String userId);

  Future<void> setScreen(String screenName, String screenClass);

  Future<void> setUserProperties(Map<String, Object> properties);

  Future<void> logEvent(String name, {Map<String, Object>? parameters});

  Future<void> reset();
}
