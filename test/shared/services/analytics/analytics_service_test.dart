import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/shared/services/analytics/analytics_service.dart';

class _RecordingDestination implements IAnalyticsDestination {
  final bool fail;
  final List<String> calls = [];

  _RecordingDestination({this.fail = false});

  Future<void> _record(String call) async {
    if (fail) throw Exception('boom');
    calls.add(call);
  }

  @override
  Future<void> setUser(String userId) => _record('user:$userId');

  @override
  Future<void> setScreen(String screenName, String screenClass) => _record('screen:$screenName');

  @override
  Future<void> setUserProperties(Map<String, Object> properties) => _record('props:$properties');

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) => _record('event:$name');

  @override
  Future<void> reset() => _record('reset');
}

void main() {
  test('every call reaches all destinations, even when one fails', () async {
    final errors = <Object>[];
    final first = _RecordingDestination();
    final last = _RecordingDestination();
    final analytics = AnalyticsService([first, _RecordingDestination(fail: true), last], logError: (error, _) => errors.add(error));

    await analytics.setScreen('Home', 'HomePage');
    await analytics.logEvent('logout');

    expect(first.calls, ['screen:Home', 'event:logout']);
    expect(last.calls, ['screen:Home', 'event:logout']);
    expect(errors, hasLength(2));
  });

  test('unchanged user properties are not sent again until reset', () async {
    final destination = _RecordingDestination();
    final analytics = AnalyticsService([destination]);

    await analytics.setUserProperties({'skin': 'fyx'});
    await analytics.setUserProperties({'skin': 'fyx'});
    await analytics.setUserProperties({'skin': 'dark'});
    await analytics.reset();
    await analytics.setUserProperties({'skin': 'dark'});

    expect(destination.calls, ['props:{skin: fyx}', 'props:{skin: dark}', 'reset', 'props:{skin: dark}']);
  });

  test('the fingerprint is stable, case-insensitive and hides the nickname', () {
    final fingerprint = AnalyticsService.fingerprint('Lucien');

    expect(fingerprint, AnalyticsService.fingerprint('LUCIEN'));
    expect(fingerprint, isNot(AnalyticsService.fingerprint('lucien2')));
    expect(fingerprint, hasLength(64));
    expect(fingerprint.toLowerCase(), isNot(contains('lucien')));
  });

  test('destinations receive the fingerprint, never the nickname', () async {
    final destination = _RecordingDestination();

    await AnalyticsService([destination]).setUser('Lucien');

    expect(destination.calls, ['user:${AnalyticsService.fingerprint('Lucien')}']);
  });
}
