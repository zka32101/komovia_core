import 'package:komovia_core/komovia_core.dart';
import 'package:test/test.dart';

void main() {
  const quota = DailyQuota(limit: 3);
  // Local-time instants so the tests are timezone-independent.
  final noon = DateTime(2026, 11, 1, 12);
  final sameDayLate = DateTime(2026, 11, 1, 23, 59, 59);
  final nextMidnight = DateTime(2026, 11, 2);

  group('DailyQuota.canUse', () {
    test('null stored date (never used) is allowed', () {
      expect(
          quota.canUse(storedCount: 99, storedDate: null, now: noon), isTrue);
    });

    test('below limit on the same day is allowed', () {
      expect(quota.canUse(storedCount: 2, storedDate: noon, now: sameDayLate),
          isTrue);
    });

    test('exactly at limit on the same day is not allowed', () {
      expect(quota.canUse(storedCount: 3, storedDate: noon, now: sameDayLate),
          isFalse);
    });

    test('over limit on the same day is not allowed', () {
      expect(
          quota.canUse(storedCount: 7, storedDate: noon, now: noon), isFalse);
    });

    test('resets exactly at local midnight', () {
      expect(
          quota.canUse(
              storedCount: 3, storedDate: sameDayLate, now: nextMidnight),
          isTrue);
      expect(
          quota.canUse(
              storedCount: 3,
              storedDate: sameDayLate,
              now: nextMidnight.subtract(const Duration(microseconds: 1))),
          isFalse);
    });

    test('a stored date in a past day resets the count', () {
      expect(
          quota.canUse(
              storedCount: 3,
              storedDate: noon.subtract(const Duration(days: 40)),
              now: noon),
          isTrue);
    });

    test('limit 0 never allows', () {
      const none = DailyQuota(limit: 0);
      expect(none.canUse(storedCount: 0, storedDate: null, now: noon), isFalse);
    });

    test('UTC stored date is compared by local day', () {
      expect(
          quota.canUse(
              storedCount: 3, storedDate: noon.toUtc(), now: sameDayLate),
          isFalse);
    });
  });

  group('DailyQuota.remaining / usedToday', () {
    test('counts down within the day and clamps at 0', () {
      expect(quota.remaining(storedCount: 1, storedDate: noon, now: noon), 2);
      expect(quota.remaining(storedCount: 5, storedDate: noon, now: noon), 0);
    });

    test('stale day and null both give a full quota', () {
      expect(
          quota.remaining(storedCount: 3, storedDate: noon, now: nextMidnight),
          3);
      expect(quota.remaining(storedCount: 3, storedDate: null, now: noon), 3);
    });

    test('negative stored count is clamped', () {
      expect(quota.usedToday(storedCount: -2, storedDate: noon, now: noon), 0);
    });
  });

  group('DailyQuota.recordUse', () {
    test('first ever use stores (1, now)', () {
      final r = quota.recordUse(storedCount: 0, storedDate: null, now: noon);
      expect(r.count, 1);
      expect(r.date, noon);
    });

    test('same-day use increments', () {
      final r =
          quota.recordUse(storedCount: 2, storedDate: noon, now: sameDayLate);
      expect(r.count, 3);
      expect(r.date, sameDayLate);
    });

    test('new-day use restarts at 1', () {
      final r = quota.recordUse(
          storedCount: 3, storedDate: sameDayLate, now: nextMidnight);
      expect(r.count, 1);
      expect(r.date, nextMidnight);
    });

    test('round-trips: limit uses then blocked, next day allowed again', () {
      var count = 0;
      DateTime? date;
      for (var i = 0; i < 3; i++) {
        expect(quota.canUse(storedCount: count, storedDate: date, now: noon),
            isTrue);
        final r =
            quota.recordUse(storedCount: count, storedDate: date, now: noon);
        count = r.count;
        date = r.date;
      }
      expect(quota.canUse(storedCount: count, storedDate: date, now: noon),
          isFalse);
      expect(
          quota.canUse(storedCount: count, storedDate: date, now: nextMidnight),
          isTrue);
    });
  });

  group('DailyQuota.isSameLocalDay', () {
    test('true within a day, false across midnight', () {
      expect(DailyQuota.isSameLocalDay(noon, sameDayLate), isTrue);
      expect(DailyQuota.isSameLocalDay(sameDayLate, nextMidnight), isFalse);
    });
  });
}
