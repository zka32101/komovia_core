import 'game_result.dart';
import 'move.dart';
import 'position.dart';

/// The rules of one board game (shogi, go, chess, ...), parameterized over
/// its concrete [Position] type [P].
///
/// Implementations must be pure rules + notation, with no dependency on
/// Flutter or any game-specific UI, so the same implementation runs
/// identically on-device, on a server, and inside the contract tests in
/// `package:komovia_core/testkit.dart`.
abstract interface class Game<P extends Position> {
  /// Stable identifier used as a key across shared services (matching,
  /// rating, ranking, daily problems, ...). Lowercase, e.g. `'shogi'`,
  /// `'go'`, `'chess'`.
  String get id;

  /// The standard starting position.
  ///
  /// [options] carries game-specific setup (board size for go, a handicap
  /// for shogi/go, ...); implementations ignore keys they don't recognize
  /// rather than throwing, so callers can pass one options map across
  /// games.
  P initialPosition({Map<String, Object?> options = const {}});

  /// Every move legal for `position.sideToMove` in [position].
  ///
  /// Does not include [ResignMove] — resigning is always available
  /// independent of the position; see [apply].
  List<Move> legalMoves(P position);

  /// Applies [move] to [position] and returns the resulting position.
  /// [position] itself is left unmodified.
  ///
  /// Accepts any move in [legalMoves(position)], plus a [ResignMove] for
  /// `position.sideToMove` at any time. Throws [ArgumentError] for any
  /// other move.
  P apply(P position, Move move);

  /// The outcome of [position], or [GameResult.ongoing] if play continues.
  ///
  /// [history] is the sequence of positions leading up to and including
  /// [position] (oldest first) — needed for repetition (千日手) and ko
  /// (コウ) checks. Games that don't need history may ignore it.
  GameResult result(P position, {List<P> history = const []});

  /// Serializes [position] in this game's standard notation (SFEN for
  /// shogi, SGF for go, FEN for chess).
  String encode(P position);

  /// Parses notation produced by [encode] back into a [Position]. Throws
  /// [FormatException] on invalid input.
  P decode(String notation);
}
