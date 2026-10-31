import 'package:komovia_core/komovia_core.dart';
import 'package:test/test.dart';

void main() {
  group('TimeControl', () {
    test('untimed has no initial duration and is not timed', () {
      const tc = TimeControl.untimed();
      expect(tc.initial, isNull);
      expect(tc.isTimed, isFalse);
    });

    test('a given initial duration is timed', () {
      const tc = TimeControl(initial: Duration(minutes: 5));
      expect(tc.initial, const Duration(minutes: 5));
      expect(tc.isTimed, isTrue);
    });
  });

  group('GameSessionKind.isTimedGame', () {
    test('ai games are never timed', () {
      expect(GameSessionKind.ai.isTimedGame, isFalse);
    });

    test('pvp games are timed', () {
      expect(GameSessionKind.pvp.isTimedGame, isTrue);
    });
  });

  group('clampRemaining', () {
    test('a positive duration is unchanged', () {
      expect(clampRemaining(const Duration(seconds: 5)),
          const Duration(seconds: 5));
    });

    test('a negative duration clamps to zero', () {
      expect(clampRemaining(const Duration(seconds: -1)), Duration.zero);
    });

    test('zero stays zero', () {
      expect(clampRemaining(Duration.zero), Duration.zero);
    });
  });

  group('isExpired', () {
    test('zero remaining is expired', () {
      expect(isExpired(Duration.zero), isTrue);
    });

    test('negative remaining is expired', () {
      expect(isExpired(const Duration(seconds: -1)), isTrue);
    });

    test('any positive remaining is not expired', () {
      expect(isExpired(const Duration(milliseconds: 1)), isFalse);
    });
  });

  group('warningLevelFor', () {
    test('above 1 minute is normal', () {
      expect(warningLevelFor(const Duration(minutes: 1, seconds: 1)),
          ClockWarningLevel.normal);
    });

    test('exactly 1 minute is low (inclusive threshold)', () {
      expect(
          warningLevelFor(const Duration(minutes: 1)), ClockWarningLevel.low);
    });

    test('between 10s and 1 minute is low', () {
      expect(
          warningLevelFor(const Duration(seconds: 30)), ClockWarningLevel.low);
    });

    test('exactly 10 seconds is critical (inclusive threshold)', () {
      expect(warningLevelFor(const Duration(seconds: 10)),
          ClockWarningLevel.critical);
    });

    test('under 10 seconds is critical', () {
      expect(warningLevelFor(const Duration(seconds: 1)),
          ClockWarningLevel.critical);
    });

    test('custom thresholds are honored', () {
      expect(
        warningLevelFor(
          const Duration(seconds: 90),
          lowThreshold: const Duration(minutes: 2),
          criticalThreshold: const Duration(seconds: 30),
        ),
        ClockWarningLevel.low,
      );
    });
  });

  group('formatClock', () {
    test('minutes and seconds pad to 2 digits', () {
      expect(formatClock(const Duration(minutes: 1, seconds: 5)), '01:05');
    });

    test('shows centiseconds under 60 seconds when enabled', () {
      expect(formatClock(const Duration(seconds: 9, milliseconds: 340)),
          '00:09.34');
    });

    test('omits centiseconds at or above 60 seconds even when enabled', () {
      expect(formatClock(const Duration(minutes: 1)), '01:00');
    });

    test('omits centiseconds when showCentiseconds is false', () {
      expect(
        formatClock(const Duration(seconds: 9, milliseconds: 340),
            showCentiseconds: false),
        '00:09',
      );
    });

    test('a negative duration formats as 00:00', () {
      expect(formatClock(const Duration(seconds: -5)), '00:00.00');
    });
  });
}
