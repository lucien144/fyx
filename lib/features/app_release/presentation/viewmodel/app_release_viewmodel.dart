import 'package:flutter/foundation.dart';
import 'package:fyx/controllers/log_service.dart';
import 'package:fyx/features/app_release/domain/repositories/app_release_repository.dart';
import 'package:fyx/features/app_release/presentation/viewmodel/app_release_state.dart';
import 'package:fyx/model/MainRepository.dart';

/// Tells whether a newer production build is published and drives the red
/// dots on the menu button and on "Sleduj vývoj Fyxu".
class AppReleaseViewModel extends ChangeNotifier {
  final AppReleaseRepository _repository;
  final int Function() _getCurrentBuild;
  final void Function(Object error, StackTrace stack) _logError;

  AppReleaseViewModel(
    this._repository, {
    int Function()? getCurrentBuild,
    void Function(Object error, StackTrace stack)? logError,
  })  : _getCurrentBuild = getCurrentBuild ?? _installedBuild,
        _logError = logError ?? _captureError;

  static int _installedBuild() => int.tryParse(MainRepository().packageInfo.buildNumber) ?? 0;

  static void _captureError(Object error, StackTrace stack) => LogService.captureError(error, stack: stack);

  AppReleaseState _state = const AppReleaseState();
  bool _checking = false;

  AppReleaseState get state => _state;

  /// Loads the cache, then checks Supabase in the background.
  Future<void> init() async {
    final currentBuild = _getCurrentBuild();
    _state = AppReleaseState(
      latest: await _repository.getCached(),
      installed: await _repository.getCachedInstalled(currentBuild),
      currentBuild: currentBuild,
      menuSeenBuild: await _repository.getMenuSeenBuild(),
      postOpenedBuild: await _repository.getPostOpenedBuild(),
    );
    notifyListeners();
    await check();
  }

  /// Fetches the newest release unless the last check is recent, and the
  /// installed build's release until it is found. A failure keeps what is known.
  Future<void> check() async {
    if (_checking) return;
    _checking = true;
    try {
      final latest = await _repository.refreshIfDue();
      _state = _state.copyWith(latest: latest, clearLatest: latest == null);
      notifyListeners();
      if (_state.installed == null) {
        final installed = await _repository.refreshInstalled(_state.currentBuild);
        if (installed != null) {
          _state = _state.copyWith(installed: installed);
          notifyListeners();
        }
      }
    } catch (e, stack) {
      _logError(e, stack);
    } finally {
      _checking = false;
    }
  }

  /// The menu was opened: hide its dot until a newer release appears.
  Future<void> markMenuSeen() async {
    final update = _state.update;
    if (!_state.showMenuDot || update == null) return;
    _state = _state.copyWith(menuSeenBuild: update.build);
    notifyListeners();
    await _repository.setMenuSeenBuild(update.build);
  }

  /// The changelog post was opened: hide its dot until a newer release appears.
  Future<void> markPostOpened() async {
    final update = _state.update;
    if (!_state.showPostDot || update == null) return;
    _state = _state.copyWith(postOpenedBuild: update.build);
    notifyListeners();
    await _repository.setPostOpenedBuild(update.build);
  }
}
