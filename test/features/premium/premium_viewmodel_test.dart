import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/features/premium/domain/entities/premium_status.dart';
import 'package:fyx/features/premium/domain/enums/premium_freshness.dart';
import 'package:fyx/features/premium/domain/repositories/premium_repository.dart';
import 'package:fyx/features/premium/presentation/viewmodel/premium_viewmodel.dart';

class _FakeRepository implements PremiumRepository {
  PremiumStatus? cached;
  PremiumStatus? remote;
  bool throwOnRefresh = false;
  int refreshCalls = 0;

  @override
  Future<PremiumStatus?> getCached(String nickname) async => cached;

  @override
  Future<PremiumStatus> refresh(String nickname) async {
    refreshCalls++;
    if (throwOnRefresh) throw Exception('supabase down');
    return remote!;
  }
}

void main() {
  final now = DateTime(2026, 8, 10, 12);
  late _FakeRepository repo;

  PremiumViewModel vm({String? nickname = 'lucien144'}) =>
      PremiumViewModel(repo, getNickname: () => nickname, clock: () => now, logError: (_, __) {});

  PremiumStatus status({DateTime? validTo, bool isGod = false, DateTime? fetchedAt}) =>
      PremiumStatus(nickname: 'lucien144', isGod: isGod, validTo: validTo, fetchedAt: fetchedAt ?? now);

  setUp(() => repo = _FakeRepository());

  test('init with a fresh cache does not refresh', () async {
    repo.cached = status(validTo: DateTime(2026, 9, 1));
    final viewModel = vm();
    await viewModel.init();
    expect(viewModel.state.isPremium, true);
    expect(viewModel.state.freshness, PremiumFreshness.fresh);
    expect(repo.refreshCalls, 0);
  });

  test('init with a stale cache triggers a background refresh', () async {
    repo.cached = status(fetchedAt: now.subtract(const Duration(days: 2))); // negative, past 24h TTL
    repo.remote = status(validTo: DateTime(2026, 9, 1));
    final viewModel = vm();
    await viewModel.init();
    await pumpEventQueue();
    expect(repo.refreshCalls, 1);
    expect(viewModel.state.isPremium, true);
  });

  test('failed refresh keeps premium on during grace', () async {
    // Fetched while still valid; validTo passed 5 days ago -> grace.
    repo.cached = status(validTo: DateTime(2026, 8, 5), fetchedAt: DateTime(2026, 8, 1));
    repo.throwOnRefresh = true;
    final viewModel = vm();
    await viewModel.init();
    await pumpEventQueue();
    expect(viewModel.state.isPremium, true);
    expect(viewModel.state.freshness, PremiumFreshness.grace);
    expect(viewModel.state.lastRefreshFailed, true);
    expect(viewModel.state.isRefreshing, false);
  });

  test('successful "not premium" answer turns premium off', () async {
    repo.cached = status(validTo: DateTime(2026, 8, 5), fetchedAt: DateTime(2026, 8, 1)); // grace
    repo.remote = status(); // negative
    final viewModel = vm();
    await viewModel.init();
    await pumpEventQueue();
    expect(viewModel.state.isPremium, false);
    expect(viewModel.state.lastRefreshFailed, false);
  });

  test('expired grace turns premium off even without a successful refresh', () async {
    repo.cached = status(validTo: DateTime(2026, 7, 1), fetchedAt: DateTime(2026, 6, 1)); // grace long over
    repo.throwOnRefresh = true;
    final viewModel = vm();
    await viewModel.init();
    await pumpEventQueue();
    expect(viewModel.state.isPremium, false);
    expect(viewModel.state.freshness, PremiumFreshness.expired);
  });

  test('refreshIfStale does nothing when fresh', () async {
    repo.cached = status(validTo: DateTime(2026, 9, 1));
    final viewModel = vm();
    await viewModel.init();
    await viewModel.refreshIfStale();
    expect(repo.refreshCalls, 0);
  });

  test('init without a nickname yields the empty state', () async {
    final viewModel = vm(nickname: null);
    await viewModel.init();
    expect(viewModel.state.freshness, PremiumFreshness.none);
    expect(viewModel.state.isPremium, false);
    expect(repo.refreshCalls, 0);
  });

  test('clear resets the state', () async {
    repo.cached = status(isGod: true);
    final viewModel = vm();
    await viewModel.init();
    viewModel.clear();
    expect(viewModel.state.status, isNull);
    expect(viewModel.state.isPremium, false);
  });

  group('Christmas unlock', () {
    PremiumViewModel vmAt(DateTime Function() clock) =>
        PremiumViewModel(repo, getNickname: () => 'lucien144', clock: clock, logError: (_, __) {});

    test('unlocks features for a non-premium user without making them premium', () async {
      final christmas = DateTime(2026, 12, 26);
      repo.cached = status(fetchedAt: christmas);
      final viewModel = vmAt(() => christmas);
      await viewModel.init();
      expect(viewModel.state.isPremium, false);
      expect(viewModel.state.isUnlocked, true);
    });

    test('unlocks features for a user with no cached status', () async {
      final christmas = DateTime(2026, 12, 24);
      repo.remote = status(fetchedAt: christmas);
      final viewModel = vmAt(() => christmas);
      await viewModel.init();
      expect(viewModel.state.isUnlocked, true);
    });

    test('ends on resume once the window is over', () async {
      var clock = DateTime(2026, 12, 31, 23);
      repo.cached = status(fetchedAt: clock);
      final viewModel = vmAt(() => clock);
      await viewModel.init();
      expect(viewModel.state.isUnlocked, true);

      clock = DateTime(2027, 1, 1, 0, 5);
      await viewModel.refreshIfStale();
      expect(viewModel.state.isUnlocked, false);
    });

    test('premium stays unlocked outside the window', () async {
      repo.cached = status(validTo: DateTime(2026, 9, 1));
      final viewModel = vm();
      await viewModel.init();
      expect(viewModel.state.isUnlocked, true);
    });
  });
}
