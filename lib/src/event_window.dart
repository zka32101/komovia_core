/// A simple time-boxed feature window (e.g. "play chess with shogi rules,
/// available Nov 1-15 only"), shared by the Komovia sibling apps for any
/// feature they want to run as a limited-time event rather than always-on.
///
/// Deliberately a plain Dart data class with no Firebase/Remote Config
/// dependency, the same way [PromotedApp] is kept Flutter-free — each app
/// supplies the start/end instants however it fetches them (Remote Config,
/// a hardcoded roster, etc.) and this class only answers "is it active
/// right now".
class EventWindow {
  const EventWindow({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  /// True iff [now] falls within `[start, end)`. [now] defaults to the
  /// real current time; pass an explicit value in tests.
  bool isActive([DateTime? now]) {
    final at = (now ?? DateTime.now()).toUtc();
    final startUtc = start.toUtc();
    final endUtc = end.toUtc();
    return !at.isBefore(startUtc) && at.isBefore(endUtc);
  }

  /// Remaining time until [end], or [Duration.zero] if already ended or
  /// not yet active hasn't started (callers checking "time left" should
  /// also check [isActive] first).
  Duration remaining([DateTime? now]) {
    final at = (now ?? DateTime.now()).toUtc();
    final endUtc = end.toUtc();
    if (at.isAfter(endUtc)) return Duration.zero;
    return endUtc.difference(at);
  }

  /// Parses a Remote-Config-style pair of ISO-8601 strings, returning
  /// null if either is missing/empty/malformed — callers should treat a
  /// null result as "no event configured" (feature stays in its default
  /// always-on-or-always-off state) rather than throwing.
  static EventWindow? tryParse({
    required String? startIso,
    required String? endIso,
  }) {
    if (startIso == null || endIso == null) return null;
    if (startIso.isEmpty || endIso.isEmpty) return null;
    final start = DateTime.tryParse(startIso);
    final end = DateTime.tryParse(endIso);
    if (start == null || end == null) return null;
    if (!end.isAfter(start)) return null;
    return EventWindow(start: start, end: end);
  }
}
