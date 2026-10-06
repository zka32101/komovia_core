import 'package:komovia_core/komovia_core.dart';

/// A minimal `Game<Position>` implementation used only to exercise
/// komovia_core's interfaces and contract-test harness end-to-end.
/// Tic-tac-toe is not a real Komovia game — it is the smallest board game
/// that still has a board, turns, a win/draw condition, and a notation to
/// round-trip, so it is cheap to keep correct as a fixture.
class TicTacToePosition extends Position {
  /// Length-9, row-major (index = rank * 3 + file). null = empty.
  final List<Side?> cells;

  @override
  final Side sideToMove;

  /// Set once a side resigns; null while the game continues normally.
  final Side? resignedBy;

  const TicTacToePosition({
    required this.cells,
    required this.sideToMove,
    this.resignedBy,
  });

  TicTacToePosition copyWith({
    List<Side?>? cells,
    Side? sideToMove,
    Side? resignedBy,
  }) {
    return TicTacToePosition(
      cells: cells ?? this.cells,
      sideToMove: sideToMove ?? this.sideToMove,
      resignedBy: resignedBy ?? this.resignedBy,
    );
  }
}
