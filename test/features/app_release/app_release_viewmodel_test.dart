import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/features/app_release/domain/entities/app_release.dart';
import 'package:fyx/features/app_release/domain/repositories/app_release_repository.dart';
import 'package:fyx/features/app_release/presentation/viewmodel/app_release_viewmodel.dart';

class _FakeRepository implements AppReleaseRepository {
  AppRelease? cached;
  AppRelease? remote;
  bool throwError = false;
  int? menuSeen;
  int? postOpened;
  AppRelease? cachedInstalled;
  AppRelease? remoteInstalled;
  int installedFetches = 0;

  @override
  Future<AppRelease?> getCached() async => cached;
  @override
  Future<AppRelease?> refreshIfDue() async {
    if (throwError) throw Exception('supabase down');
    return cached = remote;
  }

  @override
  Future<AppRelease?> getCachedInstalled(int currentBuild) async => cachedInstalled;
  @override
  Future<AppRelease?> refreshInstalled(int currentBuild) async {
    installedFetches++;
    return cachedInstalled ??= remoteInstalled;
  }

  @override
  Future<int?> getMenuSeenBuild() async => menuSeen;
  @override
  Future<void> setMenuSeenBuild(int build) async => menuSeen = build;
  @override
  Future<int?> getPostOpenedBuild() async => postOpened;
  @override
  Future<void> setPostOpenedBuild(int build) async => postOpened = build;
}

AppRelease _release(int build) => AppRelease(build: build, version: '12.2.1', postUrl: '/discussion/24237/id/$build');

void main() {
  late _FakeRepository repository;
  late List<Object> errors;

  AppReleaseViewModel viewModel({int currentBuild = 195}) =>
      AppReleaseViewModel(repository, getCurrentBuild: () => currentBuild, logError: (error, _) => errors.add(error));

  setUp(() {
    repository = _FakeRepository();
    errors = [];
  });

  test('a newer release lights both dots', () async {
    repository.remote = _release(196);
    final vm = viewModel();
    await vm.init();

    expect(vm.state.update, _release(196));
    expect(vm.state.showMenuDot, isTrue);
    expect(vm.state.showPostDot, isTrue);
  });

  test('the same or an older release shows no dots', () async {
    for (final build in [195, 194]) {
      repository.remote = _release(build);
      final vm = viewModel();
      await vm.init();

      expect(vm.state.update, isNull, reason: 'build $build');
      expect(vm.state.showMenuDot || vm.state.showPostDot, isFalse, reason: 'build $build');
    }
  });

  test('opening the menu hides only the menu dot and remembers the build', () async {
    repository.remote = _release(196);
    final vm = viewModel();
    await vm.init();

    await vm.markMenuSeen();

    expect(vm.state.showMenuDot, isFalse);
    expect(vm.state.showPostDot, isTrue);
    expect(repository.menuSeen, 196);
  });

  test('opening the post hides its dot and remembers the build', () async {
    repository.remote = _release(196);
    final vm = viewModel();
    await vm.init();

    await vm.markPostOpened();

    expect(vm.state.showPostDot, isFalse);
    expect(repository.postOpened, 196);
  });

  test('dismissed dots return for a newer release', () async {
    repository
      ..remote = _release(197)
      ..menuSeen = 196
      ..postOpened = 196;
    final vm = viewModel();
    await vm.init();

    expect(vm.state.showMenuDot, isTrue);
    expect(vm.state.showPostDot, isTrue);
  });

  test('marking without an update stores nothing', () async {
    final vm = viewModel();
    await vm.init();

    await vm.markMenuSeen();
    await vm.markPostOpened();

    expect(repository.menuSeen, isNull);
    expect(repository.postOpened, isNull);
  });

  test('a failed check keeps the cached release and logs the error', () async {
    repository
      ..cached = _release(196)
      ..throwError = true;
    final vm = viewModel();
    await vm.init();

    expect(vm.state.showMenuDot, isTrue);
    expect(errors, hasLength(1));
  });

  test('the installed release is loaded once and then kept', () async {
    repository.remoteInstalled = _release(195);
    final vm = viewModel();
    await vm.init();
    await vm.check();

    expect(vm.state.installed, _release(195));
    expect(repository.installedFetches, 1);
  });

  test('a cached installed release needs no fetch', () async {
    repository.cachedInstalled = _release(195);
    final vm = viewModel();
    await vm.init();

    expect(vm.state.installed, _release(195));
    expect(repository.installedFetches, 0);
  });

  test('a missing installed release is retried on the next check', () async {
    final vm = viewModel();
    await vm.init();
    await vm.check();

    expect(vm.state.installed, isNull);
    expect(repository.installedFetches, 2);
  });
}
