import 'move.dart';
import 'position.dart';
import 'side.dart';

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
  /// defines and documents its own scale (e.g. komovia_shogi's AI maps
  /// its own "depth 0 = shuffle a random legal move" onto the weakest
  /// level). [timeBudget], if given, bounds how long the search may run —
  /// komovia_shogi's `AI.bestMoveTimed` iteratively deepens until the
  /// budget is spent rather than searching to a fixed depth. Returns null
  /// if [position] has no legal moves.
  Future<Move?> bestMove(P position, {required int level, Duration? timeBudget});

  /// A static evaluation of [position], fixed to [Side.first]'s
  /// perspective: positive favors [Side.first], 0 is balanced, negative
  /// favors [Side.second]. The scale is game-defined (centipawn-like for
  /// shogi/chess, a score difference for go).
  ///
  /// Deliberately fixed to one side rather than relative to
  /// `position.sideToMove`: komovia_shogi's `AI.eval` already works this
  /// way ("先手視点、正=先手有利"), and a running advantage display across
  /// a whole game (as `BoardPainter`'s `advantageRatio` overlay does)
  /// needs a reference that doesn't flip sign every ply just because the
  /// turn changed.
  Future<double> evaluate(P position);

  /// Searches specifically for a forced win for `position.sideToMove`
  /// within [maxPly] plies — shogi's 詰め (mate search), generalized.
  ///
  /// Distinct from [bestMove]: komovia_shogi's engine uses a dedicated
  /// mate search (`AI.findMate`, bounded by ply and a node budget) rather
  /// than general alpha-beta at a high level/time budget, both to solve
  /// tsume puzzles and as a fast pre-check inside `bestMoveTimed`. Go and
  /// chess are expected to generalize this to life-and-death reading and
  /// mate search respectively; exact semantics for those are deferred
  /// until komovia_go/komovia_chess are built.
  ///
  /// Returns null if no forced win within [maxPly] is found — that does
  /// not mean none exists beyond [maxPly].
  Future<Move?> findForcedWin(P position, {required int maxPly});
}
