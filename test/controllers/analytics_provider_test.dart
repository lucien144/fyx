import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/log_service.dart';

class _RecordingProvider implements IAnalyticsProvider {
  final bool fail;
  final List<String> calls = [];

  _RecordingProvider({this.fail = false});

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

class _SilentLog implements ILogProvider {
  final List<Object> errors = [];

  @override
  captureError(error, {stack}) => errors.add(error);

  @override
  log(String message) {}

  @override
  setUser(String userId) {}
}

void main() {
  final log = _SilentLog();
  LogService.init(provider: log);

  test('every call reaches all providers, even when one fails', () async {
    final first = _RecordingProvider();
    final broken = _RecordingProvider(fail: true);
    final last = _RecordingProvider();
    AnalyticsProvider.init([first, broken, last]);

    await AnalyticsProvider().setScreen('Home', 'HomePage');
    await AnalyticsProvider().logEvent('logout');

    expect(first.calls, ['screen:Home', 'event:logout']);
    expect(last.calls, ['screen:Home', 'event:logout']);
    expect(log.errors, hasLength(2));
  });

  test('unchanged user properties are not sent again until reset', () async {
    final provider = _RecordingProvider();
    AnalyticsProvider.init([provider]);

    await AnalyticsProvider().setUserProperties({'skin': 'fyx'});
    await AnalyticsProvider().setUserProperties({'skin': 'fyx'});
    await AnalyticsProvider().setUserProperties({'skin': 'dark'});
    await AnalyticsProvider().reset();
    await AnalyticsProvider().setUserProperties({'skin': 'dark'});

    expect(provider.calls, ['props:{skin: fyx}', 'props:{skin: dark}', 'reset', 'props:{skin: dark}']);
  });

  test('the fingerprint is stable, case-insensitive and hides the nickname', () {
    final fingerprint = AnalyticsProvider.fingerprint('Lucien');

    expect(fingerprint, AnalyticsProvider.fingerprint('LUCIEN'));
    expect(fingerprint, isNot(AnalyticsProvider.fingerprint('lucien2')));
    expect(fingerprint, hasLength(64));
    expect(fingerprint.toLowerCase(), isNot(contains('lucien')));
  });

  test('providers receive the fingerprint, never the nickname', () async {
    final provider = _RecordingProvider();
    AnalyticsProvider.init([provider]);

    await AnalyticsProvider().setUser('Lucien');

    expect(provider.calls, ['user:${AnalyticsProvider.fingerprint('Lucien')}']);
  });
}
