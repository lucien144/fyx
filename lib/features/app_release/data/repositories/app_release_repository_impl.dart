import 'dart:io';

import 'package:fyx/features/app_release/data/datasources/app_release_local_datasource.dart';
import 'package:fyx/features/app_release/data/datasources/app_release_remote_datasource.dart';
import 'package:fyx/features/app_release/data/models/app_release_model.dart';
import 'package:fyx/features/app_release/domain/entities/app_release.dart';
import 'package:fyx/features/app_release/domain/repositories/app_release_repository.dart';

class AppReleaseRepositoryImpl implements AppReleaseRepository {
  static const checkInterval = Duration(hours: 6);

  final AppReleaseLocalDatasource _local;
  final AppReleaseRemoteDatasource _remote;
  final DateTime Function() _clock;
  final String _platform;

  /// Read on every check, so the caller can decide by the environment set after DI.
  final Duration Function() _checkInterval;

  AppReleaseRepositoryImpl(this._local, this._remote, {DateTime Function()? clock, String? platform, Duration Function()? checkInterval})
      : _clock = clock ?? DateTime.now,
        _platform = platform ?? (Platform.isIOS ? 'ios' : 'android'),
        _checkInterval = checkInterval ?? (() => AppReleaseRepositoryImpl.checkInterval);

  @override
  Future<AppRelease?> getCached() async => (await _local.readRelease())?.toEntity();

  @override
  Future<AppRelease?> refreshIfDue() async {
    final now = _clock();
    final checkedAt = await _local.readCheckedAt();
    // A check time in the future (changed clock) counts as due.
    if (checkedAt != null && !checkedAt.isAfter(now) && now.difference(checkedAt) < _checkInterval()) {
      return getCached();
    }

    final row = await _remote.fetchLatest(_platform);
    final model = row == null ? null : AppReleaseModel.fromRow(row);
    await _local.writeRelease(model);
    await _local.writeCheckedAt(now);
    return model?.toEntity();
  }

  @override
  Future<AppRelease?> getCachedInstalled(int currentBuild) async => (await _local.readInstalled(currentBuild))?.toEntity();

  @override
  Future<AppRelease?> refreshInstalled(int currentBuild) async {
    final cached = await _local.readInstalled(currentBuild);
    if (cached != null) return cached.toEntity();

    final row = await _remote.fetchUpTo(_platform, currentBuild);
    if (row == null) return null;
    final model = AppReleaseModel.fromRow(row);
    await _local.writeInstalled(currentBuild, model);
    return model.toEntity();
  }

  @override
  Future<int?> getMenuSeenBuild() => _local.readMenuSeenBuild();

  @override
  Future<void> setMenuSeenBuild(int build) => _local.writeMenuSeenBuild(build);

  @override
  Future<int?> getPostOpenedBuild() => _local.readPostOpenedBuild();

  @override
  Future<void> setPostOpenedBuild(int build) => _local.writePostOpenedBuild(build);
}
