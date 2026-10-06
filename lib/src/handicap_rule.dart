import 'position.dart';

/// A handicap applied to a game's standard starting position: piece
/// removal (将棋の駒落ち), extra stones (囲碁の置き石), or an odds
/// condition (チェスのナイトオッズ).
abstract interface class HandicapRule<P extends Position> {
  /// Stable identifier, e.g. `'2-piece'`, `'6-stone'`, `'knight-odds'`.
  String get id;

  /// Human-readable label in the game's own vocabulary (e.g. `'二枚落ち'`).
  String get label;

  /// Applies this handicap to [standardInitialPosition] (as returned by
  /// `Game.initialPosition()`), returning the handicapped starting
  /// position.
  ///
  /// Also responsible for `sideToMove` on the result, since who moves
  /// first can itself depend on the handicap: komovia_shogi's 駒落ち
  /// always keeps the same side (下手) moving first as in an even game
  /// (confirmed against `kouki-shogi`'s `_initBoard`, which only removes
  /// pieces), but go's 置き石 conventionally has White move first
  /// instead of Black, since the handicap stones already stand in for
  /// Black's usual first move.
  P apply(P standardInitialPosition);
}
