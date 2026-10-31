import 'package:komovia_core/komovia_core.dart';
import 'package:test/test.dart';

void main() {
  const policy = AbandonmentForfeitPolicy(threshold: Duration(minutes: 10));
  final last = DateTime.utc(2026, 11, 1, 12);

  group('AbandonmentForfeitPolicy.canClaim', () {
    test('false before threshold', () {
      expect(
          policy.canClaim(
              isClaimantsTurn: false,
              lastActivityAt: last,
              now: last.add(const Duration(minutes: 9, seconds: 59))),
          isFalse);
    });

    test('true exactly at threshold (inclusive)', () {
      expect(
          policy.canClaim(
              isClaimantsTurn: false,
              lastActivityAt: last,
              now: last.add(const Duration(minutes: 10))),
          isTrue);
    });

    test('true after threshold', () {
      expect(
          policy.canClaim(
              isClaimantsTurn: false,
              lastActivityAt: last,
              now: last.add(const Duration(days: 3))),
          isTrue);
    });

    test('never claimable on the claimant\'s own turn', () {
      expect(
          policy.canClaim(
              isClaimantsTurn: true,
              lastActivityAt: last,
              now: last.add(const Duration(days: 30))),
          isFalse);
    });

    test('null lastActivityAt is not claimable', () {
      expect(
          policy.canClaim(
              isClaimantsTurn: false,
              lastActivityAt: null,
              now: last.add(const Duration(days: 30))),
          isFalse);
    });

    test('handles non-UTC inputs consistently', () {
      expect(
          policy.canClaim(
              isClaimantsTurn: false,
              lastActivityAt: last.toLocal(),
              now: last.add(const Duration(minutes: 10))),
          isTrue);
    });

    test('slow preset uses 48 hours', () {
      expect(AbandonmentForfeitPolicy.slow.threshold,
          const Duration(hours: 48));
      expect(
          AbandonmentForfeitPolicy.slow.canClaim(
              isClaimantsTurn: false,
              lastActivityAt: last,
              now: last.add(const Duration(hours: 47))),
          isFalse);
    });
  });

  group('AbandonmentForfeitPolicy.remaining', () {
    test('positive before threshold', () {
      expect(
          policy.remaining(
              lastActivityAt: last, now: last.add(const Duration(minutes: 4))),
          const Duration(minutes: 6));
    });

    test('zero at and after threshold', () {
      expect(
          policy.remaining(
              lastActivityAt: last, now: last.add(const Duration(minutes: 10))),
          Duration.zero);
      expect(
          policy.remaining(
              lastActivityAt: last, now: last.add(const Duration(hours: 1))),
          Duration.zero);
    });

    test('zero for null lastActivityAt', () {
      expect(policy.remaining(lastActivityAt: null, now: last), Duration.zero);
    });
  });
}
