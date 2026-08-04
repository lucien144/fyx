import 'package:fyx/features/premium/domain/entities/premium_status.dart';

abstract class PremiumRepository {
  /// Cached status for [nickname] (lowercase); null when there is no cache or
  /// the cache belongs to a different nickname.
  Future<PremiumStatus?> getCached(String nickname);

  /// Fetches the subscriber from Supabase, persists and returns the new
  /// status. Throws on network/Supabase failure — the caller keeps whatever
  /// it already has.
  Future<PremiumStatus> refresh(String nickname);
}
