/// Pure decision logic for "the opponent has stalled / disconnected — can
/// the waiting player claim the game as a forfeit win?", shared by the
/// Komovia sibling apps so each one doesn't reimplement (and subtly
/// diverge on) the same date math.
///
/// Deliberately knows nothing about Firestore, game ids, or uids — the same
/// way [EventWindow] is Firebase-free. Each app reads its own game document,
/// builds an [AbandonmentForfeitPolicy] with whatever threshold suits its
/// format (e.g. minutes for quick games, 48 hours for slow ones), asks
/// [canClaim], and then performs the actual forfeit write in its own
/// service layer (ideally re-checking inside a transaction).
class AbandonmentForfeitPolicy {
  const AbandonmentForfeitPolicy({required this.threshold});

  /// How long the game must have been idle before a forfeit is claimable.
  /// Must be positive.
  final Duration threshold;

  /// The long threshold already used by komovia_go/komovia_chess.
  static const AbandonmentForfeitPolicy slow =
      AbandonmentForfeitPolicy(threshold: Duration(hours: 48));

  /// True iff the claimant is the WAITING player ([isClaimantsTurn] is
  /// false — the delinquent side is the one on turn) and at least
  /// [threshold] has elapsed since [lastActivityAt] (inclusive at exactly
  /// the threshold). A null [lastActivityAt] (never recorded) is never
  /// claimable — callers should fall back to e.g. the creation time.
  /// [now] defaults to the real current time; pass it explicitly in tests.
  bool canClaim({
    required bool isClaimantsTurn,
    required DateTime? lastActivityAt,
    DateTime? now,
  }) {
    if (isClaimantsTurn || lastActivityAt == null) return false;
    return remaining(lastActivityAt: lastActivityAt, now: now) == Duration.zero;
  }

  /// Time left until a forfeit becomes claimable, or [Duration.zero] once
  /// it is (or for a null [lastActivityAt], with [canClaim] still false).
  /// Independent of whose turn it is — check [canClaim] for eligibility.
  Duration remaining({required DateTime? lastActivityAt, DateTime? now}) {
    if (lastActivityAt == null) return Duration.zero;
    final at = (now ?? DateTime.now()).toUtc();
    final claimableAt = lastActivityAt.toUtc().add(threshold);
    if (!at.isBefore(claimableAt)) return Duration.zero;
    return claimableAt.difference(at);
  }
}
