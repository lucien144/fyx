import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fyx/features/premium/domain/enums/premium_freshness.dart';

part 'premium_status.freezed.dart';

/// The locally known answer to "does this user have premium?", together with
/// the evidence for it. Freshness/grace semantics are defined in ADR 0002.
@freezed
class PremiumStatus with _$PremiumStatus {
  const PremiumStatus._();

  const factory PremiumStatus({
    /// Whose status this is (lowercase).
    required String nickname,
    required bool isGod,
    DateTime? validTo,
    required DateTime fetchedAt,
  }) = _PremiumStatus;

  static const godTtl = Duration(days: 7);
  static const gracePeriod = Duration(days: 7);
  static const negativeTtl = Duration(hours: 24);

  /// Whether the remote said "premium" at the time of the fetch.
  bool get wasPremiumAtFetch => isGod || (validTo?.isAfter(fetchedAt) ?? false);

  PremiumFreshness freshnessAt(DateTime now) {
    DateTime? freshUntil;
    if (isGod) freshUntil = fetchedAt.add(godTtl);
    if (validTo != null && validTo!.isAfter(fetchedAt)) {
      if (freshUntil == null || validTo!.isAfter(freshUntil)) freshUntil = validTo;
    }
    if (freshUntil == null) {
      // Negative result: no grace, only a retry TTL.
      return now.isBefore(fetchedAt.add(negativeTtl)) ? PremiumFreshness.fresh : PremiumFreshness.stale;
    }
    if (now.isBefore(freshUntil)) return PremiumFreshness.fresh;
    if (now.isBefore(freshUntil.add(gracePeriod))) return PremiumFreshness.grace;
    return PremiumFreshness.expired;
  }

  /// Effective premium: only a successful "not premium" answer or the end of
  /// the grace period turns premium off.
  bool isPremiumAt(DateTime now) => wasPremiumAtFetch && freshnessAt(now) != PremiumFreshness.expired;
}
