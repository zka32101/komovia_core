import 'package:komovia_core/komovia_core.dart';
import 'package:test/test.dart';

void main() {
  group('computeDailyStreak', () {
    test('counts consecutive active days from today backward', () async {
      final activeDays = {0, 1, 2, 3};
      final streak = await computeDailyStreak(
        (daysAgo) async => activeDays.contains(daysAgo),
      );
      expect(streak, 4);
    });

    test('stops at the first missed day', () async {
      final activeDays = {0, 1, 2};
      final streak = await computeDailyStreak(
        (daysAgo) async => activeDays.contains(daysAgo),
      );
      expect(streak, 3);
    });

    test(
      'with todayIsLenient (default), a missing today does not break an intact streak',
      () async {
        final activeDays = {1, 2, 3};
        final streak = await computeDailyStreak(
          (daysAgo) async => activeDays.contains(daysAgo),
        );
        expect(streak, 3);
      },
    );

    test(
      'with todayIsLenient: false, a missing today resets the streak to 0',
      () async {
        final activeDays = {1, 2, 3};
        final streak = await computeDailyStreak(
          (daysAgo) async => activeDays.contains(daysAgo),
          todayIsLenient: false,
        );
        expect(streak, 0);
      },
    );

    test('returns 0 when there is no activity at all', () async {
      final streak = await computeDailyStreak((daysAgo) async => false);
      expect(streak, 0);
    });

    test('never looks further back than lookbackDays', () async {
      final streak = await computeDailyStreak(
        (daysAgo) async => true,
        lookbackDays: 10,
      );
      expect(streak, 10);
    });
  });
}
