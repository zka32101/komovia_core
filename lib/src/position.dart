import 'side.dart';

/// An immutable snapshot of one game's state.
///
/// Each game defines its own concrete subclass — a 9x9 board and captured
/// pieces for shogi, a goban and prisoner counts for go, an 8x8 board and
/// castling rights for chess — komovia_core only requires that it exposes
/// whose turn it is.
///
/// Positions must be immutable: [Game.apply] returns a *new* [Position]
/// rather than mutating the receiver, so callers can keep the full move
/// history a [Game.result] needs for repetition (千日手) and ko (コウ)
/// checks.
abstract class Position {
  const Position();

  Side get sideToMove;
}
