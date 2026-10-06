import 'game_record.dart';
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

  /// A cheap, `==`/`hashCode`-comparable key for [position]: equal keys
  /// mean "the same board state" for repetition/superko purposes. Two
  /// positions that differ only in ways the game's repetition rule
  /// ignores (e.g. move-count-only bookkeeping) may share a key.
  ///
  /// Exists so [legalMoves]/[apply]/[result]'s `historyKeys` can track
  /// history as these cheap keys instead of full [P] instances — a self-
  /// play loop generating training data over thousands of games only
  /// needs to keep `List<Object>` per game, not every [Position] it ever
  /// visited. A game that already has a canonical string form may just
  /// delegate to [encode].
  Object positionKey(P position);

  /// Every move legal for `position.sideToMove` in [position].
  ///
  /// Does not include [ResignMove] — resigning is always available
  /// independent of the position; see [apply].
  ///
  /// [historyKeys] is `positionKey` of every position leading up to and
  /// including [position] (oldest first). Most rules need only [position]
  /// itself (shogi, chess, simple-ko go with the ko point stored on
  /// [Position]), but a few need the full game: go's *positional superko*
  /// rule forbids recreating any earlier board, not just the immediately
  /// preceding one, which cannot be decided from [position] alone. Games
  /// that don't need history may ignore this parameter.
  List<Move> legalMoves(P position, {List<Object> historyKeys = const []});

  /// Applies [move] to [position] and returns the resulting position.
  /// [position] itself is left unmodified.
  ///
  /// Accepts any move in `legalMoves(position, historyKeys: historyKeys)`,
  /// plus a [ResignMove] for `position.sideToMove` at any time. Throws
  /// [ArgumentError] for any other move. [historyKeys] mirrors
  /// [legalMoves]'s — pass it whenever the game's legality can depend on
  /// it (e.g. go's superko) so `apply` can reject the same moves
  /// `legalMoves` would have excluded.
  P apply(P position, Move move, {List<Object> historyKeys = const []});

  /// The outcome of [position], or [GameResult.ongoing] if play continues.
  ///
  /// [historyKeys] is `positionKey` of every position leading up to and
  /// including [position] (oldest first) — needed for repetition (千日手)
  /// and ko (コウ) checks. Games that don't need history may ignore it.
  GameResult result(P position, {List<Object> historyKeys = const []});

  /// Serializes [position] — a single snapshot, not a game history — in
  /// this game's standard position notation (SFEN for shogi, FEN for
  /// chess; for go, a position-only notation such as an SGF setup node, or
  /// a simpler custom format — not full move-by-move SGF, see
  /// [exportRecord]).
  String encode(P position);

  /// Parses notation produced by [encode] back into a [Position]. Throws
  /// [FormatException] on invalid input.
  P decode(String notation);

  /// Exports [record] — the full move-by-move game, not just one position
  /// — to this game's native kifu format: KIF for shogi, SGF for go, PGN
  /// for chess. This is the "棋譜の読み書き" half of notation support,
  /// distinct from [encode]/[decode]'s single-position snapshots: SGF in
  /// particular is fundamentally a move-record format, not a position
  /// snapshot format.
  String exportRecord(GameRecord record);

  /// Parses a KIF/SGF/PGN string — produced by [exportRecord], or by
  /// another tool in the same format — into a game-agnostic [GameRecord].
  /// Throws [FormatException] on invalid input.
  GameRecord importRecord(String notation);
}
