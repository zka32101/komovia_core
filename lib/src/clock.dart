/// A player's time allotment for one game, or the explicit absence of one.
///
/// komovia_go's `GameMode.timeLimit` (seconds, `0` meaning untimed) and
/// komovia_chess's `OnlineGame.timeControlMs`/`timeControlType` (a label
/// string + a raw int) each independently encode the same idea with a
/// different "untimed" sentinel. [TimeControl.untimed] gives one
/// unambiguous way to say "no clock" instead of a per-app magic number.
///
/// Deliberately does NOT own a `Timer` or any ticking state — same split
/// as `ad_gate.dart`'s `AdRetryPolicy`: this is pure data an app's own
/// clock widget reads from, and that widget still owns its own
/// `Timer.periodic`. A shared type here cannot stop a screen from adding
/// its own countdown regardless of what this class says — see
/// [isTimedGame]'s doc comment for why "no AI-game clock" stays a
/// convention each app's AI-game screen follows, not something the type
/// system enforces.
class TimeControl {
  /// How much time each side starts with. Null means untimed.
  final Duration? initial;

  const TimeControl({required this.initial});

  const TimeControl.untimed() : initial = null;

  bool get isTimed => initial != null;
}

/// Whether a game *of this kind* should carry a [TimeControl] at all —
/// `false` for AI games (the Komovia Promise's "NO TIMERS"), `true` for
/// PvP/online games (blitz, correspondence, ranked — these are explicitly
/// exempt). A factory function that only ever returns a non-null
/// [TimeControl] when [isTimedGame] is true, and `TimeControl.untimed()`
/// otherwise, makes the AI/PvP split visible and greppable in one place —
/// but this is advisory, not enforced: nothing stops an AI-game screen
/// from building its own `Timer` and countdown display independent of
/// this value entirely. Real enforcement, if ever wanted, would need a
/// lint rule or code-review convention, not a Dart type.
enum GameSessionKind {
  ai,
  pvp;

  bool get isTimedGame => this == GameSessionKind.pvp;
}

/// How urgently a clock's remaining time should be presented —
/// generalizes komovia_chess's `TimeClock` widget's inline thresholds
/// (yellow under 1 minute, red under 10 seconds, pulsing animation at
/// red) into pure, UI-framework-free logic so any app's own clock widget
/// can share the same thresholds instead of re-deriving them.
enum ClockWarningLevel { normal, low, critical }

/// [remaining] clamped so it's never negative — a tick that fires after
/// expiry (clock drift, a delayed callback) should read as exactly
/// expired, not as a negative time display.
Duration clampRemaining(Duration remaining) {
  return remaining.isNegative ? Duration.zero : remaining;
}

/// Whether a clock showing [remaining] has expired.
bool isExpired(Duration remaining) => remaining <= Duration.zero;

/// [remaining]'s urgency level, using komovia_chess's `TimeClock`
/// thresholds (critical under 10s, low under 1 minute) as the shared
/// default.
ClockWarningLevel warningLevelFor(
  Duration remaining, {
  Duration lowThreshold = const Duration(minutes: 1),
  Duration criticalThreshold = const Duration(seconds: 10),
}) {
  if (remaining <= criticalThreshold) return ClockWarningLevel.critical;
  if (remaining <= lowThreshold) return ClockWarningLevel.low;
  return ClockWarningLevel.normal;
}

/// Formats [remaining] as `MM:SS`, or `MM:SS.C` (centiseconds) when
/// [remaining] is under a minute and [showCentiseconds] is true —
/// matches komovia_chess's `TimeClock` display convention so any app's
/// clock widget can format consistently without reimplementing the
/// digit math.
String formatClock(Duration remaining, {bool showCentiseconds = true}) {
  final clamped = clampRemaining(remaining);
  final minutes = clamped.inMinutes;
  final seconds = clamped.inSeconds % 60;
  final mmss = '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
  if (!showCentiseconds || clamped.inSeconds >= 60) return mmss;
  final centiseconds = (clamped.inMilliseconds % 1000) ~/ 10;
  return '$mmss.${centiseconds.toString().padLeft(2, '0')}';
}
