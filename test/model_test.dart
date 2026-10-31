import 'package:komovia_core/komovia_core.dart';
import 'package:test/test.dart';

void main() {
  group('Side', () {
    test('opponent flips first/second', () {
      expect(Side.first.opponent, Side.second);
      expect(Side.second.opponent, Side.first);
    });
  });

  group('Square', () {
    test('equality and hashCode are by value', () {
      expect(const Square(1, 2), const Square(1, 2));
      expect(const Square(1, 2).hashCode, const Square(1, 2).hashCode);
      expect(const Square(1, 2), isNot(const Square(2, 1)));
    });
  });

  group('Move', () {
    test('BoardMove equality is by value, including promote', () {
      const a = BoardMove(from: Square(0, 0), to: Square(0, 1));
      const b = BoardMove(from: Square(0, 0), to: Square(0, 1));
      const c = BoardMove(from: Square(0, 0), to: Square(0, 1), promote: true);
      expect(a, b);
      expect(a, isNot(c));
    });

    test('DropMove, PassMove, ResignMove equality is by value', () {
      expect(
        const DropMove(pieceType: 'P', to: Square(2, 2)),
        const DropMove(pieceType: 'P', to: Square(2, 2)),
      );
      expect(const PassMove(), const PassMove());
      expect(const ResignMove(Side.first), const ResignMove(Side.first));
      expect(const ResignMove(Side.first), isNot(const ResignMove(Side.second)));
    });

    test('Move is a closed (sealed) set switchable without a default case', () {
      String describe(Move move) => switch (move) {
            BoardMove() => 'board',
            DropMove() => 'drop',
            PassMove() => 'pass',
            ResignMove() => 'resign',
          };
      expect(describe(const PassMove()), 'pass');
      expect(describe(const ResignMove(Side.second)), 'resign');
    });
  });

  group('GameResult', () {
    test('ongoing reports isOngoing and no winner/reason', () {
      expect(GameResult.ongoing.isOngoing, isTrue);
      expect(GameResult.ongoing.winner, isNull);
      expect(GameResult.ongoing.reason, isNull);
    });

    test('win carries a winner and reason, and is not ongoing', () {
      const result = GameResult.win(Side.first, WinReason.checkmate);
      expect(result.isOngoing, isFalse);
      expect(result.winner, Side.first);
      expect(result.reason, WinReason.checkmate);
    });

    test('draw has no winner', () {
      const result = GameResult.draw(WinReason.repetition);
      expect(result.isOngoing, isFalse);
      expect(result.winner, isNull);
      expect(result.reason, WinReason.repetition);
    });
  });

  group('GameRecord / RecordedMove', () {
    test('can describe a short game end-to-end', () {
      const record = GameRecord(
        gameId: 'tictactoe',
        moves: [
          RecordedMove(number: 1, side: Side.first, move: DropMove(pieceType: 'mark', to: Square(1, 1))),
          RecordedMove(number: 2, side: Side.second, move: DropMove(pieceType: 'mark', to: Square(0, 0))),
        ],
        result: GameResult.ongoing,
        metadata: {'event': 'komovia_core unit test'},
      );
      expect(record.moves, hasLength(2));
      expect(record.metadata['event'], 'komovia_core unit test');
    });
  });

  group('Puzzle', () {
    test('holds a position and a solution line', () {
      const puzzle = Puzzle(
        id: 'p1',
        gameId: 'tictactoe',
        position: _FakePosition(Side.first),
        solution: [DropMove(pieceType: 'mark', to: Square(1, 1))],
      );
      expect(puzzle.solution, hasLength(1));
      expect(puzzle.position.sideToMove, Side.first);
    });
  });
}

class _FakePosition extends Position {
  @override
  final Side sideToMove;
  const _FakePosition(this.sideToMove);
}
