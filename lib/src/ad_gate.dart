import 'entitlement.dart';

/// Whether ads should be shown to a user holding [entitlement], at [now]
/// (defaults to the real current time).
///
/// A single source of truth for the one check komovia_go's
/// `showGameEndInterstitialProvider` and `AdBanner.build()` each
/// independently re-implemented (`!isSubscriptionActiveProvider`) — both
/// happen to agree today, but duplicating the same gate per ad surface is
/// exactly how a future edit to one and not the other turns into a real
/// "ads shown to a subscriber" regression. A shared app composes this with
/// its own `Entitlement`-backed provider instead of re-deriving the check.
bool shouldShowAds(Entitlement entitlement, {DateTime? now}) {
  return !entitlement.isCurrentlyActive(now: now);
}

/// Exponential-backoff retry policy for a transient ad-load failure —
/// generalizes komovia_go's `AdBannerRetryPolicy` (added there to fix a
/// real regression: a single failed banner load used to permanently zero
/// that screen's ad revenue, since nothing ever retried). A pure function
/// — no `Timer`, no ad SDK — so any sibling app's ad widget can schedule
/// its own retry `Timer` using this as the delay source, and the policy
/// itself is unit-testable with no platform channel involved.
class AdRetryPolicy {
  const AdRetryPolicy._();

  static const defaultMaxRetries = 3;
  static const defaultBaseDelay = Duration(seconds: 5);

  /// How long to wait before retrying after the [attemptNumber]th failure
  /// (1-based: 1 means "the first failure just happened, this is the
  /// delay before retry #1"). Returns null once [attemptNumber] exceeds
  /// [maxRetries] — the caller should give up rather than retry forever.
  ///
  /// Delay doubles each attempt (1x, 2x, 4x, ... [baseDelay]) — matches
  /// komovia_go's original 5s/10s/20s sequence at the defaults.
  static Duration? delayForAttempt(
    int attemptNumber, {
    int maxRetries = defaultMaxRetries,
    Duration baseDelay = defaultBaseDelay,
  }) {
    if (attemptNumber < 1 || attemptNumber > maxRetries) return null;
    return baseDelay * (1 << (attemptNumber - 1));
  }
}
