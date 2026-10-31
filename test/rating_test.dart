import 'package:komovia_core/komovia_core.dart';
import 'package:test/test.dart';

void main() {
  group('computeEloDelta', () {
    test('equal ratings: win gains half the K-factor', () {
      final delta = computeEloDelta(
        currentRating: 1200,
        opponentRating: 1200,
        score: 1.0,
      );
      expect(delta, 12); // K=24 * (1 - 0.5)
    });

    test('equal ratings: loss loses the same amount', () {
      final delta = computeEloDelta(
        currentRating: 1200,
        opponentRating: 1200,
        score: 0.0,
      );
      expect(delta, -12);
    });

    test('equal ratings: draw is exactly expected, so no change', () {
      final delta = computeEloDelta(
        currentRating: 1200,
        opponentRating: 1200,
        score: 0.5,
      );
      expect(delta, 0);
    });

    test('beating a stronger opponent gains more than beating an equal one',
        () {
      final vsEqual = computeEloDelta(
        currentRating: 1200,
        opponentRating: 1200,
        score: 1.0,
      );
      final vsStronger = computeEloDelta(
        currentRating: 1200,
        opponentRating: 1950,
        score: 1.0,
      );
      expect(vsStronger, greaterThan(vsEqual));
    });

    test('losing to a weaker opponent loses more than losing to an equal one',
        () {
      final vsEqual = computeEloDelta(
        currentRating: 1200,
        opponentRating: 1200,
        score: 0.0,
      );
      final vsWeaker = computeEloDelta(
        currentRating: 1200,
        opponentRating: 600,
        score: 0.0,
      );
      expect(vsWeaker, lessThan(vsEqual));
    });

    test('a custom kFactor scales the swing proportionally', () {
      final defaultDelta = computeEloDelta(
        currentRating: 1200,
        opponentRating: 1200,
        score: 1.0,
      );
      final doubledK = computeEloDelta(
        currentRating: 1200,
        opponentRating: 1200,
        score: 1.0,
        kFactor: 48,
      );
      expect(doubledK, defaultDelta * 2);
    });
  });

  group('ratingForAiLevel', () {
    test('the base level maps to baseRating exactly', () {
      final rating = ratingForAiLevel(
        level: 5,
        minLevel: 1,
        maxLevel: 10,
        baseLevel: 5,
      );
      expect(rating, 1200);
    });

    test('matches komovia_go\'s original 1-10/step-150 formula', () {
      expect(
        ratingForAiLevel(level: 10, minLevel: 1, maxLevel: 10, baseLevel: 5),
        1950,
      );
      expect(
        ratingForAiLevel(level: 1, minLevel: 1, maxLevel: 10, baseLevel: 5),
        600,
      );
    });

    test('clamps out-of-range levels instead of extrapolating', () {
      final atMax =
          ratingForAiLevel(level: 10, minLevel: 1, maxLevel: 10, baseLevel: 5);
      final beyondMax =
          ratingForAiLevel(level: 99, minLevel: 1, maxLevel: 10, baseLevel: 5);
      expect(beyondMax, atMax);

      final atMin =
          ratingForAiLevel(level: 1, minLevel: 1, maxLevel: 10, baseLevel: 5);
      final belowMin =
          ratingForAiLevel(level: -3, minLevel: 1, maxLevel: 10, baseLevel: 5);
      expect(belowMin, atMin);
    });

    test('a custom baseRating/step shifts and rescales the whole curve', () {
      final rating = ratingForAiLevel(
        level: 3,
        minLevel: 1,
        maxLevel: 5,
        baseLevel: 1,
        baseRating: 1000,
        step: 100,
      );
      expect(rating, 1200); // 1000 + (3-1)*100
    });
  });
}
