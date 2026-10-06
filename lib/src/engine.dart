import 'move.dart';
import 'position.dart';

/// A move-choosing / position-evaluating AI for one [Game].
///
/// Both methods are async so a lightweight on-device implementation and a
/// server-backed strong engine (same interface, a network call inside)
/// are interchangeable — see design doc §3-1 "端末内の軽量実装とサーバー
/// 強AI（v1.2）を同じ形で差し替え".
abstract interface class Engine<P extends Position> {
  /// Picks a move for `position.sideToMove`.
  ///
  /// [level] is 1 = weakest, higher = stronger; each implementation
  /// defines and documents its own scale. [timeBudget], if given, bounds
  /// how long the search may run. Returns null if [position] has no legal
  /// moves.
  Future<Move?> bestMove(P position, {required int level, Duration? timeBudget});

  /// A static evaluation of [position] from `position.sideToMove`'s
  /// perspective: positive favors the side to move, 0 is balanced. The
  /// scale is game-defined (centipawn-like for shogi/chess, a score
  /// difference for go).
  Future<double> evaluate(P position);
}
