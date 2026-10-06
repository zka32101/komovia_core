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
  P apply(P standardInitialPosition);
}
