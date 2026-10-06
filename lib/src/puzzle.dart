import 'move.dart';
import 'position.dart';

/// A position with a known correct line: shogi 詰め将棋, go 死活/手筋, or a
/// chess mate-in-N puzzle, all sharing one shape.
class Puzzle<P extends Position> {
  final String id;
  final String gameId;
  final P position;

  /// The correct move sequence, alternating sides and starting with
  /// `position.sideToMove`.
  final List<Move> solution;

  final Map<String, Object?> metadata;

  const Puzzle({
    required this.id,
    required this.gameId,
    required this.position,
    required this.solution,
    this.metadata = const {},
  });
}
