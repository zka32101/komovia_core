import 'package:komovia_core/komovia_core.dart';
import 'package:test/test.dart';

void main() {
  group('EventWindow.isActive', () {
    final window = EventWindow(
      start: DateTime.utc(2026, 11, 1),
      end: DateTime.utc(2026, 11, 15),
    );

    test('true strictly inside the window', () {
      expect(window.isActive(DateTime.utc(2026, 11, 7)), isTrue);
    });

    test('true exactly at start (inclusive)', () {
      expect(window.isActive(DateTime.utc(2026, 11, 1)), isTrue);
    });

    test('false exactly at end (exclusive)', () {
      expect(window.isActive(DateTime.utc(2026, 11, 15)), isFalse);
    });

    test('false before start', () {
      expect(window.isActive(DateTime.utc(2026, 10, 31)), isFalse);
    });

    test('false after end', () {
      expect(window.isActive(DateTime.utc(2026, 11, 16)), isFalse);
    });
  });

  group('EventWindow.remaining', () {
    final window = EventWindow(
      start: DateTime.utc(2026, 11, 1),
      end: DateTime.utc(2026, 11, 15),
    );

    test('positive duration before end', () {
      final remaining = window.remaining(DateTime.utc(2026, 11, 14));
      expect(remaining, const Duration(days: 1));
    });

    test('zero after end', () {
      expect(window.remaining(DateTime.utc(2026, 11, 16)), Duration.zero);
    });
  });

  group('EventWindow.tryParse', () {
    test('parses valid ISO strings', () {
      final window = EventWindow.tryParse(
        startIso: '2026-11-01T00:00:00Z',
        endIso: '2026-11-15T00:00:00Z',
      );
      expect(window, isNotNull);
      expect(window!.isActive(DateTime.utc(2026, 11, 7)), isTrue);
    });

    test('returns null for null input', () {
      expect(
          EventWindow.tryParse(startIso: null, endIso: '2026-11-15T00:00:00Z'),
          isNull);
      expect(
          EventWindow.tryParse(startIso: '2026-11-01T00:00:00Z', endIso: null),
          isNull);
    });

    test('returns null for empty strings', () {
      expect(EventWindow.tryParse(startIso: '', endIso: ''), isNull);
    });

    test('returns null for malformed strings', () {
      expect(
          EventWindow.tryParse(
              startIso: 'not-a-date', endIso: '2026-11-15T00:00:00Z'),
          isNull);
    });

    test('returns null when end is not after start', () {
      expect(
        EventWindow.tryParse(
          startIso: '2026-11-15T00:00:00Z',
          endIso: '2026-11-01T00:00:00Z',
        ),
        isNull,
      );
      expect(
        EventWindow.tryParse(
          startIso: '2026-11-01T00:00:00Z',
          endIso: '2026-11-01T00:00:00Z',
        ),
        isNull,
      );
    });
  });
}
