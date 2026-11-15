import 'package:flutter/foundation.dart';
import 'package:fyx/features/premium/domain/entities/premium_status.dart';
import 'package:fyx/features/premium/domain/enums/premium_freshness.dart';

/// State of the premium gate: the last known status plus the evaluation
/// derived from it ([freshness], [isPremium]) and refresh bookkeeping —
/// everything the future settings section needs to render.
@immutable
class PremiumState {
  final PremiumStatus? status;

  /// Freshness computed at the last evaluation (init/resume/refresh).
  final PremiumFreshness freshness;

  /// Effective premium at the last evaluation (fresh or grace, see ADR 0002).
  final bool isPremium;

  /// Premium features are available: [isPremium] or the Christmas unlock.
  /// Gate features on this; use [isPremium] for what belongs to subscribers only.
  final bool isUnlocked;

  final bool isRefreshing;

  /// The most recent refresh attempt threw. Cleared by a successful refresh.
  final bool lastRefreshFailed;

  const PremiumState({
    this.status,
    this.freshness = PremiumFreshness.none,
    this.isPremium = false,
    this.isUnlocked = false,
    this.isRefreshing = false,
    this.lastRefreshFailed = false,
  });

  PremiumState copyWith({
    PremiumStatus? status,
    bool clearStatus = false,
    PremiumFreshness? freshness,
    bool? isPremium,
    bool? isUnlocked,
    bool? isRefreshing,
    bool? lastRefreshFailed,
  }) {
    return PremiumState(
      status: clearStatus ? null : (status ?? this.status),
      freshness: freshness ?? this.freshness,
      isPremium: isPremium ?? this.isPremium,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      lastRefreshFailed: lastRefreshFailed ?? this.lastRefreshFailed,
    );
  }
}
