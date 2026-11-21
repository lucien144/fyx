import 'package:flutter/foundation.dart';
import 'package:fyx/features/app_release/domain/entities/app_release.dart';

@immutable
class AppReleaseState {
  final AppRelease? latest;

  /// The release the installed build belongs to; its post is the changelog.
  final AppRelease? installed;
  final int currentBuild;
  final int? menuSeenBuild;
  final int? postOpenedBuild;

  const AppReleaseState({this.latest, this.installed, this.currentBuild = 0, this.menuSeenBuild, this.postOpenedBuild});

  /// The newest release when it is newer than the installed build.
  AppRelease? get update => (latest?.isNewerThan(currentBuild) ?? false) ? latest : null;

  bool get showMenuDot => update != null && (menuSeenBuild ?? 0) < update!.build;

  bool get showPostDot => update != null && (postOpenedBuild ?? 0) < update!.build;

  AppReleaseState copyWith(
      {AppRelease? latest, bool clearLatest = false, AppRelease? installed, int? currentBuild, int? menuSeenBuild, int? postOpenedBuild}) {
    return AppReleaseState(
      latest: clearLatest ? null : (latest ?? this.latest),
      installed: installed ?? this.installed,
      currentBuild: currentBuild ?? this.currentBuild,
      menuSeenBuild: menuSeenBuild ?? this.menuSeenBuild,
      postOpenedBuild: postOpenedBuild ?? this.postOpenedBuild,
    );
  }
}
