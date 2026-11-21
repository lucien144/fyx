import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/features/app_release/data/datasources/app_release_local_datasource.dart';
import 'package:fyx/features/app_release/data/datasources/app_release_remote_datasource.dart';
import 'package:fyx/features/app_release/data/models/app_release_model.dart';
import 'package:fyx/features/app_release/data/repositories/app_release_repository_impl.dart';
import 'package:fyx/features/app_release/domain/entities/app_release.dart';

class _FakeLocal implements AppReleaseLocalDatasource {
  AppReleaseModel? release;
  DateTime? checkedAt;
  int? menuSeen;
  int? postOpened;
  AppReleaseModel? installed;
  int? installedFor;

  @override
  Future<AppReleaseModel?> readRelease() async => release;
  @override
  Future<void> writeRelease(AppReleaseModel? model) async => release = model;
  @override
  Future<DateTime?> readCheckedAt() async => checkedAt;
  @override
  Future<void> writeCheckedAt(DateTime value) async => checkedAt = value;
  @override
  Future<AppReleaseModel?> readInstalled(int currentBuild) async => installedFor == currentBuild ? installed : null;
  @override
  Future<void> writeInstalled(int currentBuild, AppReleaseModel model) async {
    installed = model;
    installedFor = currentBuild;
  }

  @override
  Future<int?> readMenuSeenBuild() async => menuSeen;
  @override
  Future<void> writeMenuSeenBuild(int build) async => menuSeen = build;
  @override
  Future<int?> readPostOpenedBuild() async => postOpened;
  @override
  Future<void> writePostOpenedBuild(int build) async => postOpened = build;
}

class _FakeRemote implements AppReleaseRemoteDatasource {
  Map<String, dynamic>? row;
  bool throwError = false;
  final List<String> platforms = [];
  Map<String, dynamic>? upToRow;
  final List<int> upToBuilds = [];

  @override
  Future<Map<String, dynamic>?> fetchLatest(String platform) async {
    platforms.add(platform);
    if (throwError) throw Exception('supabase down');
    return row;
  }

  @override
  Future<Map<String, dynamic>?> fetchUpTo(String platform, int build) async {
    upToBuilds.add(build);
    if (throwError) throw Exception('supabase down');
    return upToRow;
  }
}

void main() {
  final now = DateTime(2026, 11, 21, 12);
  const row = {'build': 196, 'version': '12.2.1', 'post_url': '/discussion/24237/id/123'};
  const release = AppRelease(build: 196, version: '12.2.1', postUrl: '/discussion/24237/id/123');
  late _FakeLocal local;
  late _FakeRemote remote;
  late AppReleaseRepositoryImpl repository;

  setUp(() {
    local = _FakeLocal();
    remote = _FakeRemote()..row = row;
    repository = AppReleaseRepositoryImpl(local, remote, clock: () => now, platform: 'ios');
  });

  test('fetches for its platform and caches the release with the check time', () async {
    expect(await repository.refreshIfDue(), release);
    expect(remote.platforms, ['ios']);
    expect(await repository.getCached(), release);
    expect(local.checkedAt, now);
  });

  test('uses the cache while the last check is within the interval', () async {
    local
      ..release = AppReleaseModel.fromRow(row)
      ..checkedAt = now.subtract(const Duration(hours: 5, minutes: 59));
    remote.row = {...row, 'build': 197};

    expect(await repository.refreshIfDue(), release);
    expect(remote.platforms, isEmpty);
  });

  test('fetches again once the interval has passed or the check time is in the future', () async {
    for (final checkedAt in [now.subtract(AppReleaseRepositoryImpl.checkInterval), now.add(const Duration(hours: 1))]) {
      local.checkedAt = checkedAt;
      await repository.refreshIfDue();
    }
    expect(remote.platforms, hasLength(2));
  });

  test('the check interval is read on every check', () async {
    var interval = const Duration(hours: 6);
    repository = AppReleaseRepositoryImpl(local, remote, clock: () => now, platform: 'ios', checkInterval: () => interval);
    local.checkedAt = now.subtract(const Duration(seconds: 30));

    await repository.refreshIfDue();
    interval = const Duration(seconds: 20);
    local.checkedAt = now.subtract(const Duration(seconds: 30));
    await repository.refreshIfDue();

    expect(remote.platforms, hasLength(1));
  });

  test('no published release clears the cache', () async {
    local.release = AppReleaseModel.fromRow(row);
    remote.row = null;

    expect(await repository.refreshIfDue(), isNull);
    expect(await repository.getCached(), isNull);
  });

  test('a failed fetch throws and keeps the cache and the check time', () async {
    local.release = AppReleaseModel.fromRow(row);
    remote.throwError = true;

    await expectLater(repository.refreshIfDue(), throwsException);
    expect(await repository.getCached(), release);
    expect(local.checkedAt, isNull);
  });

  group('installed release', () {
    const installedRow = {'build': 195, 'version': '12.2.0', 'post_url': '/discussion/24237/id/100'};

    test('is fetched up to the installed build and cached for it', () async {
      remote.upToRow = installedRow;

      expect((await repository.refreshInstalled(195))?.build, 195);
      expect((await repository.refreshInstalled(195))?.build, 195);
      expect(remote.upToBuilds, [195]);
      expect((await repository.getCachedInstalled(195))?.postUrl, '/discussion/24237/id/100');
    });

    test('is fetched again after an update', () async {
      remote.upToRow = installedRow;
      await repository.refreshInstalled(195);

      expect(await repository.getCachedInstalled(196), isNull);
      await repository.refreshInstalled(196);
      expect(remote.upToBuilds, [195, 196]);
    });

    test('a miss is not cached, so the next check asks again', () async {
      expect(await repository.refreshInstalled(195), isNull);
      await repository.refreshInstalled(195);

      expect(remote.upToBuilds, [195, 195]);
    });
  });
}
