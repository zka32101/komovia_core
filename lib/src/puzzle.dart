import 'move.dart';
import 'position.dart';

/// A position with a known correct line: shogi 詰め将棋, go 死活/手筋, or a
/// chess mate-in-N puzzle, all sharing one shape.
class Puzzle<P extends Position> {
  final String id;
  final String gameId;

  /// A short display title (e.g. `'1手詰め ①'`, `'lishogi #1234 (1500)'`).
  /// Promoted to its own field — not left in [metadata] — because every
  /// puzzle source in komovia_shogi's prior art (hand-made tsume, tesuji
  /// drills, imported lishogi puzzles) carries one and the puzzle list UI
  /// always needs it.
  final String? title;

  final P position;

  /// The correct move sequence, alternating sides and starting with
  /// `position.sideToMove`.
  final List<Move> solution;

  /// Everything else that varies by puzzle source and game: a difficulty
  /// label or numeric rating, a tesuji/theme category, a teaching
  /// explanation, tags, ... — deliberately not first-class fields, since
  /// each source shapes these differently (a difficulty *label* for
  /// hand-made tsume vs. a Glicko *rating* for imported puzzles).
  final Map<String, Object?> metadata;

  const Puzzle({
    required this.id,
    required this.gameId,
    required this.position,
    required this.solution,
    this.title,
    this.metadata = const {},
  });
}
