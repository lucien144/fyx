import 'dart:convert';

import 'package:fyx/features/app_release/data/models/app_release_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the last known release, the time of the last check and which
/// release the dots were dismissed for. Corrupt content reads as "no cache".
class AppReleaseLocalDatasource {
  static const _releaseKey = 'app_release_latest';
  static const _checkedAtKey = 'app_release_checked_at';
  static const _menuSeenKey = 'app_release_menu_seen_build';
  static const _postOpenedKey = 'app_release_post_opened_build';
  static const _installedKey = 'app_release_installed';
  static const _installedForBuildKey = 'app_release_installed_for_build';

  Future<AppReleaseModel?> readRelease() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_releaseKey);
    if (raw == null) return null;
    try {
      return AppReleaseModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      await prefs.remove(_releaseKey);
      return null;
    }
  }

  Future<void> writeRelease(AppReleaseModel? model) async {
    final prefs = await SharedPreferences.getInstance();
    if (model == null) {
      await prefs.remove(_releaseKey);
    } else {
      await prefs.setString(_releaseKey, jsonEncode(model.toJson()));
    }
  }

  Future<DateTime?> readCheckedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_checkedAtKey);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<void> writeCheckedAt(DateTime checkedAt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_checkedAtKey, checkedAt.toIso8601String());
  }

  /// The installed build's release, only when it was stored for [currentBuild].
  Future<AppReleaseModel?> readInstalled(int currentBuild) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_installedKey);
    if (raw == null || prefs.getInt(_installedForBuildKey) != currentBuild) return null;
    try {
      return AppReleaseModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      await prefs.remove(_installedKey);
      return null;
    }
  }

  Future<void> writeInstalled(int currentBuild, AppReleaseModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_installedKey, jsonEncode(model.toJson()));
    await prefs.setInt(_installedForBuildKey, currentBuild);
  }

  Future<int?> readMenuSeenBuild() async => (await SharedPreferences.getInstance()).getInt(_menuSeenKey);

  Future<void> writeMenuSeenBuild(int build) async => (await SharedPreferences.getInstance()).setInt(_menuSeenKey, build);

  Future<int?> readPostOpenedBuild() async => (await SharedPreferences.getInstance()).getInt(_postOpenedKey);

  Future<void> writePostOpenedBuild(int build) async => (await SharedPreferences.getInstance()).setInt(_postOpenedKey, build);
}
