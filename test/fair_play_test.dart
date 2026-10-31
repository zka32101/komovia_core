import 'dart:math';

import 'package:komovia_core/komovia_core.dart';
import 'package:test/test.dart';

/// Deterministic pseudo-random helper so "realistic variance" test games
/// aren't flaky between runs.
List<double> _seededLosses(List<double> base) => List<double>.from(base);

void main() {
  group('computeFairPlaySignal - edge cases', () {
    test('empty move list yields the empty/no-signal result', () {
      final signal = computeFairPlaySignal(const []);
      expect(signal.sampleSize, 0);
      expect(signal.suspicionScore, 0);
      expect(signal.reviewRecommended, isFalse);
    });

    test('single move never recommends review regardless of value', () {
      final clean = computeFairPlaySignal(const [0]);
      expect(clean.sampleSize, 1);
      expect(clean.suspicionScore, 0);
      expect(clean.reviewRecommended, isFalse);

      final lossy = computeFairPlaySignal(const [500]);
      expect(lossy.reviewRecommended, isFalse);
    });
  });

  group('computeFairPlaySignal - short game', () {
    test('a short, extremely clean game is NOT flagged - sample too small', () {
      // 10 moves, every one matching the engine's exact top choice -
      // exactly the kind of "looks suspicious" short run the design doc
      // calls out as a weak signal on its own (a short forced tactical
      // sequence can look like this for a genuinely honest player).
      final losses = List<double>.filled(10, 0);
      final signal = computeFairPlaySignal(losses);

      expect(signal.sampleSize, 10);
      expect(signal.meanCentipawnLoss, 0);
      // Below minMovesForFairPlaySignal -> zero score, no matter how
      // clean the underlying stats are.
      expect(signal.suspicionScore, 0);
      expect(signal.reviewRecommended, isFalse);
    });
  });

  group('computeFairPlaySignal - clearly clean (realistic human) game', () {
    test('moderate mean loss with real variance, long game: not flagged', () {
      // A realistic strong-human distribution: average a bit below the
      // "clean" baseline but with real move-to-move spread (occasional
      // bigger slips, several near-perfect moves) - 40 moves.
      final rand = Random(7);
      final losses = List<double>.generate(40, (i) {
        // Mix of small/medium losses with real variance, mean ~ 25-45cp.
        final base = 10 + rand.nextDouble() * 60;
        return base;
      });
      final signal = computeFairPlaySignal(_seededLosses(losses));

      expect(signal.sampleSize, 40);
      expect(signal.meanCentipawnLoss, greaterThan(15));
      expect(signal.stdDevCentipawnLoss, greaterThan(5));
      expect(signal.reviewRecommended, isFalse);
      expect(signal.suspicionScore, lessThan(fairPlayReviewThreshold));
    });
  });

  group('computeFairPlaySignal - clearly suspicious game', () {
    test('very low loss, very low variance, long game: flagged for review', () {
      // 80 half-moves, essentially always matching the engine's top
      // choice with only tiny noise - the "engine-assisted" profile the
      // design targets: low mean, low variance, sustained over a long
      // game.
      final rand = Random(42);
      final losses = List<double>.generate(
        80,
        (i) => rand.nextDouble() * 3, // 0-3cp noise, basically perfect
      );
      final signal = computeFairPlaySignal(losses);

      expect(signal.sampleSize, 80);
      expect(signal.meanCentipawnLoss, lessThan(5));
      expect(signal.stdDevCentipawnLoss, lessThan(10));
      expect(signal.topMoveMatchRate, greaterThan(0.9));
      expect(
          signal.suspicionScore, greaterThanOrEqualTo(fairPlayReviewThreshold));
      expect(signal.reviewRecommended, isTrue);
    });

    test(
        'same clean stats but only just past the floor: weaker score than the long game',
        () {
      final rand = Random(42);
      final shortClean = List<double>.generate(
          minMovesForFairPlaySignal, (i) => rand.nextDouble() * 3);
      final longClean = List<double>.generate(
          movesForFullFairPlayConfidence, (i) => rand.nextDouble() * 3);

      final shortSignal = computeFairPlaySignal(shortClean);
      final longSignal = computeFairPlaySignal(longClean);

      // Same underlying "cleanliness", but the longer game's sustained
      // pattern should score at least as suspicious, reflecting the
      // sample-size ramp.
      expect(longSignal.suspicionScore,
          greaterThanOrEqualTo(shortSignal.suspicionScore));
    });
  });

  group('computeFairPlaySignal - monotonicity sanity checks', () {
    test('lower mean loss (all else equal) never decreases the score', () {
      final higherLoss = List<double>.filled(40, 40);
      final lowerLoss = List<double>.filled(40, 5);

      final higher = computeFairPlaySignal(higherLoss);
      final lower = computeFairPlaySignal(lowerLoss);

      expect(lower.suspicionScore, greaterThanOrEqualTo(higher.suspicionScore));
    });

    test('topMoveMatchRate is computed correctly', () {
      final losses = [0.0, 0.0, 5.0, 100.0, 300.0];
      final signal = computeFairPlaySignal(losses);
      // 3 of 5 moves (0, 0, 5) are within topMoveMatchCpTolerance (10cp).
      expect(signal.topMoveMatchRate, closeTo(3 / 5, 1e-9));
    });
  });
}
