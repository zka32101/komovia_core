import 'game_result.dart';
import 'move.dart';
import 'side.dart';

/// One recorded move: what was played, by whom, and (optionally) how it
/// reads in the game's own notation and how long it took.
class RecordedMove {
  final int number;
  final Side side;
  final Move move;

  /// Human-readable notation for this move (e.g. `'▲7六歩'`, `'e4'`).
  /// Optional — filled in only when exporting to a game's native format.
  final String? notation;
  final Duration? elapsed;

  const RecordedMove({
    required this.number,
    required this.side,
    required this.move,
    this.notation,
    this.elapsed,
  });
}

/// A game-agnostic kifu: the common shape that shogi (KIF), go (SGF), and
/// chess (PGN) records all convert to/from, so komovia_core's services
/// (backup, sharing, replay) don't need to know which game produced a
/// given record.
class GameRecord {
  final String gameId;

  /// The starting position, in `Game.encode` form. Null means the game's
  /// standard initial position.
  final String? initialPositionNotation;

  final List<RecordedMove> moves;
  final GameResult result;

  /// Free-form headers (players, date, event, time control, ...), mirroring
  /// KIF/PGN header conventions.
  final Map<String, String> metadata;

  const GameRecord({
    required this.gameId,
    required this.moves,
    required this.result,
    this.initialPositionNotation,
    this.metadata = const {},
  });
}
