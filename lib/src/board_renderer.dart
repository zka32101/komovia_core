import 'move.dart';
import 'position.dart';
import 'square.dart';

/// A 2D size in board-local units.
///
/// Deliberately not `dart:ui`'s `Size` — komovia_core has no Flutter
/// dependency. Each game's Flutter-side implementation of [BoardRenderer]
/// converts to/from `dart:ui` at its own boundary.
class BoardSize {
  final double width;
  final double height;
  const BoardSize(this.width, this.height);
}

/// A 2D offset in board-local units. See [BoardSize].
class BoardOffset {
  final double dx;
  final double dy;
  const BoardOffset(this.dx, this.dy);
}

/// Builds the renderable board for a [Position] and converts taps/clicks
/// back to board [Square]s.
///
/// [W] is a Flutter `Widget` in every real implementation — left generic
/// so komovia_core itself stays Flutter-free. [build] returns [W] rather
/// than painting onto an externally supplied canvas: komovia_shogi's actual
/// board (checked against `zka32101/kouki-shogi`'s `MiniBoardWidget`) is a
/// `StatelessWidget` that composes a background `CustomPainter`
/// (`BoardPainter`) with one piece-shaped `CustomPainter` (`KomaPainter`)
/// per occupied square inside a widget tree — not one flat
/// `paint(Canvas, ...)` call — so the shared contract needs to hand back
/// something a game screen can drop into its widget tree, not a canvas
/// callback. A game is free to implement [build] with `CustomPaint`
/// layers, a plain widget tree, or anything else that produces a [W].
abstract interface class BoardRenderer<P extends Position, W> {
  /// Builds the board for [position].
  ///
  /// [lastMove] highlights the most recent move, [hints] highlights
  /// candidate squares (e.g. legal destinations for a selected piece, or a
  /// puzzle hint), and [selected] highlights the currently selected square.
  W build(
    P position, {
    Move? lastMove,
    List<Square> hints = const [],
    Square? selected,
  });

  /// Converts a tap/click at [offset], within a surface sized [size], to
  /// the board square it falls on — or null if [offset] is outside the
  /// board.
  Square? squareAt(BoardOffset offset, BoardSize size, P position);
}
