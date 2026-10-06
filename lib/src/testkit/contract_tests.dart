import 'package:test/test.dart';

import '../game.dart';
import '../game_result.dart';
import '../move.dart';
import '../position.dart';

/// Runs komovia_core's shared contract tests against [game].
///
/// Every game package (komovia_shogi, komovia_go, ...) calls this from its
/// own `test/` directory so core and each game agree on what "a legal
/// `Game` implementation" means — see design doc §2b "契約テスト" and §6
/// stage-1 passing condition. This is deliberately a *skeleton*: legal
/// moves, win/loss, notation round-trip, and position serialization, not
/// an exhaustive rules checker for any one game.
///
/// [samplePosition] should return a position reachable from
/// `game.initialPosition()` (the initial position itself is fine) to
/// exercise [Game.encode]/[Game.decode].
void runGameContractTests<P extends Position>(
  Game<P> game, {
  required P Function() samplePosition,
}) {
  group('${game.id} contract', () {
    test('id is non-empty', () {
      expect(game.id, isNotEmpty);
    });

    test('initialPosition has a side to move', () {
      final pos = game.initialPosition();
      expect(pos.sideToMove, isNotNull);
    });

    test('legalMoves on the initial position is non-empty', () {
      final pos = game.initialPosition();
      expect(game.legalMoves(pos), isNotEmpty);
    });

    test('every legal move can be applied without throwing', () {
      final pos = game.initialPosition();
      for (final move in game.legalMoves(pos)) {
        game.apply(pos, move);
      }
    });

    test('apply does not mutate its input position', () {
      final pos = game.initialPosition();
      final before = game.encode(pos);
      final legal = game.legalMoves(pos);
      if (legal.isNotEmpty) {
        game.apply(pos, legal.first);
      }
      expect(game.encode(pos), before);
    });

    test('result is ongoing on a fresh initial position', () {
      final pos = game.initialPosition();
      expect(game.result(pos).isOngoing, isTrue);
    });

    test('resigning immediately ends the game for the opponent', () {
      final pos = game.initialPosition();
      final resigning = pos.sideToMove;
      final afterResign = game.apply(pos, ResignMove(resigning));
      final result = game.result(afterResign);
      expect(result.kind, ResultKind.win);
      expect(result.winner, resigning.opponent);
      expect(result.reason, WinReason.resignation);
    });

    test('playing legal moves to the end only ever reaches a terminal '
        'result once legalMoves is exhausted or result stops being '
        'ongoing', () {
      var pos = game.initialPosition();
      var history = <P>[pos];
      const maxPly = 200; // guards against a buggy Game looping forever
      for (var i = 0; i < maxPly; i++) {
        if (!game.result(pos, history: history).isOngoing) return;
        final legal = game.legalMoves(pos);
        if (legal.isEmpty) return;
        pos = game.apply(pos, legal.first);
        history = [...history, pos];
      }
    });

    test('notation round-trip: encode(decode(encode(position))) is stable',
        () {
      final pos = samplePosition();
      final notation = game.encode(pos);
      final decoded = game.decode(notation);
      expect(game.encode(decoded), notation);
    });

    test('decode rejects garbage input', () {
      expect(
        () => game.decode('not a valid position notation \x00'),
        throwsFormatException,
      );
    });
  });
}
