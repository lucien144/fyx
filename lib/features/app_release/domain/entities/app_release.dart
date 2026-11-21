import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_release.freezed.dart';

/// The newest production release published for this platform.
@freezed
class AppRelease with _$AppRelease {
  const AppRelease._();

  const factory AppRelease({
    required int build,
    required String version,

    /// Club post with the changelog, e.g. `/discussion/24237/id/123456`.
    required String postUrl,
  }) = _AppRelease;

  bool isNewerThan(int currentBuild) => build > currentBuild;
}
