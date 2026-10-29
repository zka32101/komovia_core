/// Game-agnostic "consecutive days of activity" streak counter, shared by
/// every Komovia app's daily-puzzle/daily-login style feature (so far
/// ported from `komovia_go`'s `FirestoreService.getTsumeGoStreak` and
/// `komovia_reversia`'s `ReversiaPuzzleLogService.getStreak`, which had
/// independently implemented the exact same backward-day-walk algorithm
/// against each app's own Firestore query).
///
/// Deliberately async rather than taking a precomputed list of dates:
/// each app's own "did this uid have a qualifying activity on this day"
/// check is itself a Firestore query (or similar), and this lets the walk
/// stop early (after the first missed day) without the caller having to
/// fetch an unbounded history up front.
library;

/// Counts the number of most-recent consecutive calendar days with a
/// qualifying activity, walking backward from today.
///
/// [hasActivityOn] is called once per day, most recent first (today is
/// `daysAgo: 0`, yesterday is `daysAgo: 1`, etc.), and should resolve to
/// whether that calendar day had a qualifying activity (e.g. "solved
/// today's puzzle"). The walk stops at the first day that resolves
/// `false` and does not count that day — except today itself when
/// [todayIsLenient] is true (the default): a user who simply hasn't
/// gotten to today's activity yet shouldn't have an otherwise-intact
/// streak reset by that alone, so a `false` for `daysAgo: 0` is skipped
/// rather than treated as a break. Set [todayIsLenient] to false for the
/// simpler "any missed day breaks it, today included" behavior.
///
/// [lookbackDays] bounds how far back the walk can go (default 365,
/// matching `komovia_go`'s original `getTsumeGoStreak`) — a safety net
/// against an unbounded loop, not a feature in its own right.
Future<int> computeDailyStreak(
  Future<bool> Function(int daysAgo) hasActivityOn, {
  bool todayIsLenient = true,
  int lookbackDays = 365,
}) async {
  var streak = 0;
  for (var daysAgo = 0; daysAgo < lookbackDays; daysAgo++) {
    final active = await hasActivityOn(daysAgo);
    if (active) {
      streak++;
      continue;
    }
    if (daysAgo == 0 && todayIsLenient) continue;
    break;
  }
  return streak;
}
