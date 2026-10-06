import 'side.dart';
import 'square.dart';

/// A single move, typed by kind so games that lack one concept — chess has
/// no drop, shogi has no pass — can still share one type and switch over it
/// exhaustively (all four subclasses live in this file, which is what lets
/// [sealed] give callers a compiler-checked exhaustive switch).
///
/// This directly addresses the design risk that an interface modeled only
/// on shogi won't fit go: go's pass and ko, and shogi's drop, are each
/// first-class kinds rather than bolted onto a single move shape.
sealed class Move {
  const Move();
}

/// Moves a piece/stone already on the board from [from] to [to].
///
/// [promote] is shogi-style promotion; games without promotion simply never
/// produce a [BoardMove] with `promote: true`.
class BoardMove extends Move {
  final Square from;
  final Square to;
  final bool promote;

  const BoardMove({
    required this.from,
    required this.to,
    this.promote = false,
  });

  @override
  bool operator ==(Object other) =>
      other is BoardMove &&
      other.from == from &&
      other.to == to &&
      other.promote == promote;

  @override
  int get hashCode => Object.hash(from, to, promote);

  @override
  String toString() => 'BoardMove($from -> $to${promote ? ", promote" : ""})';
}

/// Places a piece from hand onto the board (shogi drop) or a stone onto an
/// empty point (go).
///
/// [pieceType] is a game-defined identifier (e.g. `"P"` for a shogi pawn,
/// `"stone"` for go) — komovia_core never interprets it, only carries it.
class DropMove extends Move {
  final String pieceType;
  final Square to;

  const DropMove({required this.pieceType, required this.to});

  @override
  bool operator ==(Object other) =>
      other is DropMove && other.pieceType == pieceType && other.to == to;

  @override
  int get hashCode => Object.hash(pieceType, to);

  @override
  String toString() => 'DropMove($pieceType -> $to)';
}

/// Passes the turn without changing the board (go; some endgame rules).
class PassMove extends Move {
  const PassMove();

  @override
  bool operator ==(Object other) => other is PassMove;

  @override
  int get hashCode => (PassMove).hashCode;

  @override
  String toString() => 'PassMove()';
}

/// Resigns the game on behalf of [side].
///
/// Unlike [BoardMove]/[DropMove]/[PassMove], a [ResignMove] is not expected
/// to appear in [Game.legalMoves] — resigning is always available to the
/// side to move, independent of the position. See [Game.apply].
class ResignMove extends Move {
  final Side side;

  const ResignMove(this.side);

  @override
  bool operator ==(Object other) => other is ResignMove && other.side == side;

  @override
  int get hashCode => side.hashCode;

  @override
  String toString() => 'ResignMove($side)';
}
