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

/// Draws a [Position] and converts taps/clicks back to board [Square]s.
///
/// [C] is the drawing surface — a Flutter `Canvas` in every real
/// implementation — left generic so komovia_core itself stays Flutter-free.
/// Each game package implements one `BoardRenderer<ItsPosition, Canvas>`;
/// the app layer calls it from a `CustomPainter`.
abstract interface class BoardRenderer<P extends Position, C> {
  /// Paints [position] onto [canvas], sized to [size].
  ///
  /// [lastMove] highlights the most recent move, [hints] highlights
  /// candidate squares (e.g. legal destinations for a selected piece, or a
  /// puzzle hint), and [selected] highlights the currently selected square.
  void paint(
    C canvas,
    BoardSize size,
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
