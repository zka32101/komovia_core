import 'package:komovia_core/komovia_core.dart';
import 'package:test/test.dart';

void main() {
  group('Tournament', () {
    Tournament build({String status = 'upcoming'}) => Tournament(
      id: 't1',
      name: 'Spring Open',
      description: 'desc',
      startDate: DateTime.utc(2026, 1, 1),
      endDate: DateTime.utc(2026, 1, 8),
      maxParticipants: 8,
      format: 'single_elimination',
      status: status,
      participantUids: const ['u1', 'u2'],
      createdBy: 'u1',
      boardSize: 19,
      createdAt: DateTime.utc(2025, 12, 1),
    );

    test('round-trips through toJson/fromJson', () {
      final t = build();
      final restored = Tournament.fromJson(t.toJson());
      expect(restored.id, t.id);
      expect(restored.name, t.name);
      expect(restored.participantUids, t.participantUids);
      expect(restored.createdBy, t.createdBy);
      expect(restored.boardSize, t.boardSize);
      expect(restored.createdAt, t.createdAt);
    });

    test('status getters', () {
      expect(build(status: 'upcoming').isUpcoming, isTrue);
      expect(build(status: 'active').isActive, isTrue);
      expect(build(status: 'completed').isCompleted, isTrue);
      expect(build(status: 'cancelled').isCancelled, isTrue);
    });

    test('isFull reflects participant count vs maxParticipants', () {
      final t = build();
      expect(t.isFull, isFalse);
      final full = t.copyWith(participantUids: List.filled(8, 'x'));
      expect(full.isFull, isTrue);
    });

    test('copyWith can explicitly clear winnerId to null', () {
      final t = build().copyWith(winnerId: 'u1');
      expect(t.winnerId, 'u1');
      final cleared = t.copyWith(winnerId: null);
      expect(cleared.winnerId, isNull);
    });

    test('createdBy is preserved across copyWith (immutable after creation)', () {
      final t = build();
      final updated = t.copyWith(status: 'active');
      expect(updated.createdBy, t.createdBy);
    });
  });

  group('TournamentMatch', () {
    test('round-trips through toJson/fromJson', () {
      final match = TournamentMatch(
        id: 'm1',
        tournamentId: 't1',
        player1Uid: 'u1',
        player1DisplayName: 'Alice',
        player2Uid: 'u2',
        player2DisplayName: 'Bob',
        round: 1,
        status: 'pending',
        scheduledAt: DateTime.utc(2026, 1, 1),
      );
      final restored = TournamentMatch.fromJson(match.toJson());
      expect(restored.id, match.id);
      expect(restored.player1Uid, match.player1Uid);
      expect(restored.player2DisplayName, match.player2DisplayName);
      expect(restored.round, match.round);
    });

    test('isBye is true when either player slot is empty', () {
      final bye = TournamentMatch(
        id: 'm1',
        tournamentId: 't1',
        player1Uid: 'u1',
        round: 1,
        status: 'completed',
        scheduledAt: DateTime.utc(2026, 1, 1),
      );
      expect(bye.isBye, isTrue);

      final full = bye.toJson();
      full['player2Uid'] = 'u2';
      expect(TournamentMatch.fromJson(full).isBye, isFalse);
    });

    test('status getters', () {
      TournamentMatch withStatus(String status) => TournamentMatch(
        id: 'm1',
        tournamentId: 't1',
        player1Uid: 'u1',
        player2Uid: 'u2',
        round: 1,
        status: status,
        scheduledAt: DateTime.utc(2026, 1, 1),
      );
      expect(withStatus('pending').isPending, isTrue);
      expect(withStatus('in_progress').isInProgress, isTrue);
      expect(withStatus('completed').isCompleted, isTrue);
    });
  });

  group('TournamentParticipant', () {
    test('round-trips through toJson/fromJson', () {
      final p = TournamentParticipant(
        tournamentId: 't1',
        uid: 'u1',
        displayName: 'Alice',
        seed: 1,
        joinedAt: DateTime.utc(2026, 1, 1),
      );
      final restored = TournamentParticipant.fromJson(p.toJson());
      expect(restored.uid, p.uid);
      expect(restored.displayName, p.displayName);
      expect(restored.seed, p.seed);
    });
  });

  group('TournamentStandingEntry', () {
    test('played is wins + losses', () {
      const entry = TournamentStandingEntry(
        uid: 'u1',
        displayName: 'Alice',
        wins: 3,
        losses: 2,
      );
      expect(entry.played, 5);
    });
  });
}
