import 'package:fyx/features/app_release/domain/entities/app_release.dart';

abstract class AppReleaseRepository {
  /// The last known release, without touching the network.
  Future<AppRelease?> getCached();

  /// Fetches the newest release when the last check is older than the check
  /// interval, otherwise returns the cached one. Throws on network/Supabase
  /// failure — the caller keeps whatever it already has.
  Future<AppRelease?> refreshIfDue();

  /// The release the installed build belongs to (highest build not above
  /// [currentBuild]) from the cache, when it was stored for [currentBuild].
  Future<AppRelease?> getCachedInstalled(int currentBuild);

  /// Like [getCachedInstalled], but fetches when nothing is stored for
  /// [currentBuild]. Only a found release is cached, so a miss is retried on
  /// the next check. Throws on network/Supabase failure.
  Future<AppRelease?> refreshInstalled(int currentBuild);

  /// Build the user has seen the menu dot for.
  Future<int?> getMenuSeenBuild();

  Future<void> setMenuSeenBuild(int build);

  /// Build whose changelog post the user has opened.
  Future<int?> getPostOpenedBuild();

  Future<void> setPostOpenedBuild(int build);
}
