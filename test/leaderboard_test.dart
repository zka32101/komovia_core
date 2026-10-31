import 'package:komovia_core/komovia_core.dart';
import 'package:test/test.dart';

void main() {
  group('LeaderboardEntry', () {
    test('round-trips through toJson/fromJson', () {
      final entry = LeaderboardEntry(
        uid: 'u1',
        displayName: 'Alice',
        rank: 1,
        rating: 1500,
        gamesPlayed: 10,
        wins: 7,
        winRate: 0.7,
        puzzlesSolved: 3,
        achievementsUnlocked: 2,
        tournamentWins: 1,
        lastUpdated: DateTime.utc(2026, 1, 1),
      );

      final restored = LeaderboardEntry.fromJson(entry.toJson());

      expect(restored.uid, entry.uid);
      expect(restored.displayName, entry.displayName);
      expect(restored.rank, entry.rank);
      expect(restored.rating, entry.rating);
      expect(restored.gamesPlayed, entry.gamesPlayed);
      expect(restored.wins, entry.wins);
      expect(restored.winRate, entry.winRate);
      expect(restored.puzzlesSolved, entry.puzzlesSolved);
      expect(restored.achievementsUnlocked, entry.achievementsUnlocked);
      expect(restored.tournamentWins, entry.tournamentWins);
      expect(restored.lastUpdated, entry.lastUpdated);
    });

    test('fromJson defaults missing fields', () {
      final restored = LeaderboardEntry.fromJson({'uid': 'u1'});
      expect(restored.displayName, 'Anonymous');
      expect(restored.rank, 0);
      expect(restored.rating, 1200);
      expect(restored.achievementsUnlocked, 0);
      expect(restored.tournamentWins, 0);
    });

    test('copyWith overrides only the given fields', () {
      final entry = LeaderboardEntry(
        uid: 'u1',
        displayName: 'Alice',
        rank: 5,
        rating: 1200,
        gamesPlayed: 1,
        wins: 1,
        winRate: 1.0,
        puzzlesSolved: 0,
        lastUpdated: DateTime.utc(2026, 1, 1),
      );
      final updated = entry.copyWith(rank: 1);
      expect(updated.rank, 1);
      expect(updated.uid, entry.uid);
      expect(updated.rating, entry.rating);
    });
  });

  group('LeaderboardPeriod', () {
    test('toShortString/fromString round-trip for every value', () {
      for (final period in LeaderboardPeriod.values) {
        expect(LeaderboardPeriod.fromString(period.toShortString()), period);
      }
    });

    test('fromString defaults unrecognized values to allTime', () {
      expect(LeaderboardPeriod.fromString('garbage'), LeaderboardPeriod.allTime);
    });
  });

  group('LeaderboardType', () {
    test('toShortString/fromString round-trip for every value', () {
      for (final type in LeaderboardType.values) {
        expect(LeaderboardType.fromString(type.toShortString()), type);
      }
    });

    test('fromString defaults unrecognized values to rating', () {
      expect(LeaderboardType.fromString('garbage'), LeaderboardType.rating);
    });
  });
}
