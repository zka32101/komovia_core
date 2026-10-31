/// Pure "N free uses per calendar day, reset at midnight" arithmetic,
/// shared by the Komovia sibling apps (extracted after `komovia_go` and
/// `komovia_chess` independently implemented the same quota logic for the
/// AI-analysis plan, on top of their older daily-game/daily-puzzle quotas).
///
/// Like [AbandonmentForfeitPolicy]/[EventWindow], this knows nothing about
/// Firestore, SharedPreferences, or entitlements: each app loads its own
/// stored `(count, date)`, asks [canUse], and on a use persists the value
/// returned by [recordUse]. A paid-entitlement bypass is the caller's job
/// (e.g. `if (entitlement.isCurrentlyActive() || quota.canUse(...))`).
///
/// **Day boundary: the device's LOCAL calendar day, not UTC.** Unlike
/// [AbandonmentForfeitPolicy], which measures an elapsed duration and so
/// normalizes to UTC, a daily quota is a calendar concept: users expect it
/// to reset at their own midnight, and a UTC reset would land mid-afternoon
/// or mid-morning for most Komovia users (e.g. 09:00 JST). Both [now] and
/// the stored date are converted with `toLocal()` and compared by
/// year/month/day, so it doesn't matter whether the caller stored a UTC or
/// local `DateTime` (e.g. a Firestore `Timestamp.toDate()`). No timezone
/// package is needed — `DateTime.toLocal()` uses the device's zone. The
/// trade-off is that a user who changes the device timezone can gain or
/// lose at most part of a day, which is acceptable for a free-tier quota.
class DailyQuota {
  /// [limit] is the number of uses allowed per day; must be >= 0
  /// (0 means "never allowed without a bypass").
  const DailyQuota({required this.limit}) : assert(limit >= 0);

  final int limit;

  /// The count that is in effect for today: [storedCount] if [storedDate]
  /// falls on the same local calendar day as [now], else 0 (a null
  /// [storedDate] means nothing was ever recorded). Negative stored
  /// counts are clamped to 0.
  int usedToday({
    required int storedCount,
    required DateTime? storedDate,
    DateTime? now,
  }) {
    if (storedDate == null) return 0;
    if (!isSameLocalDay(storedDate, now ?? DateTime.now())) return 0;
    return storedCount < 0 ? 0 : storedCount;
  }

  /// Uses still available today (never negative).
  int remaining({
    required int storedCount,
    required DateTime? storedDate,
    DateTime? now,
  }) {
    final used =
        usedToday(storedCount: storedCount, storedDate: storedDate, now: now);
    return used >= limit ? 0 : limit - used;
  }

  /// Whether one more use is allowed right now.
  bool canUse({
    required int storedCount,
    required DateTime? storedDate,
    DateTime? now,
  }) =>
      remaining(storedCount: storedCount, storedDate: storedDate, now: now) > 0;

  /// The `(count, date)` to persist after consuming one use at [now]:
  /// today's count plus one, and `date` = [now] itself (any instant within
  /// the day works, since comparison is by local calendar day). Does NOT
  /// check [canUse] — callers gate first; this just counts, so a bypassing
  /// (paid) user's usage can still be recorded if an app wants to.
  ({int count, DateTime date}) recordUse({
    required int storedCount,
    required DateTime? storedDate,
    DateTime? now,
  }) {
    final at = now ?? DateTime.now();
    final used =
        usedToday(storedCount: storedCount, storedDate: storedDate, now: at);
    return (count: used + 1, date: at);
  }

  /// True iff [a] and [b] fall on the same LOCAL calendar day.
  static bool isSameLocalDay(DateTime a, DateTime b) {
    final la = a.toLocal();
    final lb = b.toLocal();
    return la.year == lb.year && la.month == lb.month && la.day == lb.day;
  }
}
