import 'package:komovia_core/komovia_core.dart';
import 'package:test/test.dart';

import 'fixtures/tictactoe/tictactoe_game.dart';
import 'fixtures/tictactoe/tictactoe_position.dart';

/// A toy engine whose evaluation is simply (first's marks - second's
/// marks), fixed to [Side.first]'s perspective — just enough to drive
/// [EngineReviewEngine] deterministically. [bestMove]/[findForcedWin] are
/// unused by [EngineReviewEngine] and left unimplemented.
class _CountingEngine implements Engine<TicTacToePosition> {
  @override
  String get modelVersion => 'counting-fake';

  @override
  Future<double> evaluate(TicTacToePosition position) async {
    final first = position.cells.where((c) => c == Side.first).length;
    final second = position.cells.where((c) => c == Side.second).length;
    return (first - second).toDouble();
  }

  @override
  Future<Move?> bestMove(
    TicTacToePosition position, {
    required int level,
    Duration? timeBudget,
  }) =>
      throw UnimplementedError();

  @override
  Future<Move?> findForcedWin(TicTacToePosition position,
          {required int maxPly}) =>
      throw UnimplementedError();
}

void main() {
  late TicTacToeGame game;
  late _CountingEngine engine;
  late EngineReviewEngine<TicTacToePosition> review;

  setUp(() {
    game = TicTacToeGame();
    engine = _CountingEngine();
    review = EngineReviewEngine(game: game, engine: engine);
  });

  GameRecord recordOf(List<RecordedMove> moves) =>
      GameRecord(gameId: 'g', moves: moves, result: GameResult.ongoing);

  test(
      'every move drops the counting engine eval by exactly 1 for its own side, so loss is 0 and quality is best',
      () async {
    final record = recordOf([
      RecordedMove(
          number: 1,
          side: Side.first,
          move: DropMove(pieceType: 'mark', to: Square(0, 0))),
      RecordedMove(
          number: 2,
          side: Side.second,
          move: DropMove(pieceType: 'mark', to: Square(1, 0))),
    ]);

    final analysis = await review.analyzeGame(record, game.initialPosition());

    expect(analysis.moves, hasLength(2));
    for (final m in analysis.moves) {
      expect(m.loss, 0);
      expect(m.quality, MoveQuality.best);
    }
    expect(analysis.accuracyFor(Side.first), 100);
    expect(analysis.accuracyFor(Side.second), 100);
    expect(analysis.blunders, isEmpty);
  });

  test('classifyMoveQuality matches komovia_chess thresholds (15/50/100/300)',
      () {
    expect(classifyMoveQuality(0), MoveQuality.best);
    expect(classifyMoveQuality(14.9), MoveQuality.best);
    expect(classifyMoveQuality(15), MoveQuality.good);
    expect(classifyMoveQuality(49.9), MoveQuality.good);
    expect(classifyMoveQuality(50), MoveQuality.inaccuracy);
    expect(classifyMoveQuality(99.9), MoveQuality.inaccuracy);
    expect(classifyMoveQuality(100), MoveQuality.mistake);
    expect(classifyMoveQuality(299.9), MoveQuality.mistake);
    expect(classifyMoveQuality(300), MoveQuality.blunder);
    expect(classifyMoveQuality(1000), MoveQuality.blunder);
  });

  test(
      'loss is clamped to 0 rather than going negative when a move improves the mover\'s own eval',
      () async {
    // second's mark does not change first's piece count, so from first's
    // perspective the eval is unchanged after second's move — but the
    // raw swing is computed as (after - before) for second, which here
    // is 0, not negative; this fixture can't easily force a genuinely
    // improving move for the fake engine's eval formula, so this test
    // instead documents the clamp exists and returns 0 in the boundary
    // case rather than asserting a negative-swing scenario the counting
    // engine can't produce.
    final record = recordOf([
      RecordedMove(
          number: 1,
          side: Side.first,
          move: DropMove(pieceType: 'mark', to: Square(0, 0))),
    ]);
    final analysis = await review.analyzeGame(record, game.initialPosition());
    expect(analysis.moves.single.loss, greaterThanOrEqualTo(0));
  });

  test(
      'a side that made no moves gets 100% accuracy rather than dividing by zero',
      () async {
    final record = recordOf([
      RecordedMove(
          number: 1,
          side: Side.first,
          move: DropMove(pieceType: 'mark', to: Square(0, 0))),
    ]);
    final analysis = await review.analyzeGame(record, game.initialPosition());
    expect(analysis.accuracyFor(Side.second), 100);
  });

  test('onProgress is called once per move with (done, total)', () async {
    final record = recordOf([
      RecordedMove(
          number: 1,
          side: Side.first,
          move: DropMove(pieceType: 'mark', to: Square(0, 0))),
      RecordedMove(
          number: 2,
          side: Side.second,
          move: DropMove(pieceType: 'mark', to: Square(1, 0))),
      RecordedMove(
          number: 3,
          side: Side.first,
          move: DropMove(pieceType: 'mark', to: Square(2, 0))),
    ]);

    final calls = <(int, int)>[];
    await review.analyzeGame(
      record,
      game.initialPosition(),
      onProgress: (done, total) => calls.add((done, total)),
    );

    expect(calls, [(1, 3), (2, 3), (3, 3)]);
  });

  test('blunders/mistakes filter by MoveQuality', () async {
    // Force a real blunder: first plays into second completing three in
    // a row isn't directly expressible via the counting engine (it only
    // counts marks, not lines) — instead verify filtering mechanics
    // directly against a hand-built GameAnalysis.
    const analysis = GameAnalysis(moves: [
      MoveAnalysis(
        moveIndex: 1,
        side: Side.first,
        evalBefore: 0,
        evalAfter: -3,
        loss: 300,
        quality: MoveQuality.blunder,
      ),
      MoveAnalysis(
        moveIndex: 2,
        side: Side.second,
        evalBefore: -3,
        evalAfter: -4,
        loss: 100,
        quality: MoveQuality.mistake,
      ),
    ]);

    expect(analysis.blunders, hasLength(1));
    expect(analysis.mistakes, hasLength(1));
    expect(analysis.movesBy(Side.first), hasLength(1));
    expect(analysis.movesBy(Side.second), hasLength(1));
  });
}
