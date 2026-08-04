/// How trustworthy the cached premium status currently is. See ADR 0002.
enum PremiumFreshness {
  /// No refresh needed.
  fresh,

  /// Refresh wanted; the (non-premium) answer keeps applying meanwhile.
  stale,

  /// Expired but still honoured while refreshes keep failing.
  grace,

  /// Grace ran out; premium is off until a refresh succeeds.
  expired,

  /// No usable cache for this user.
  none,
}
