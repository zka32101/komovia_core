import 'package:komovia_core/komovia_core.dart';

import 'tictactoe_position.dart';

const _lines = [
  [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
  [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
  [0, 4, 8], [2, 4, 6], // diagonals
];

/// See [TicTacToePosition] for why this toy exists.
class TicTacToeGame implements Game<TicTacToePosition> {
  @override
  String get id => 'tictactoe';

  @override
  TicTacToePosition initialPosition({Map<String, Object?> options = const {}}) {
    return TicTacToePosition(cells: List.filled(9, null), sideToMove: Side.first);
  }

  @override
  List<Move> legalMoves(TicTacToePosition position) {
    if (!result(position).isOngoing) return const [];
    return [
      for (var i = 0; i < 9; i++)
        if (position.cells[i] == null)
          DropMove(pieceType: 'mark', to: Square(i % 3, i ~/ 3)),
    ];
  }

  @override
  TicTacToePosition apply(TicTacToePosition position, Move move) {
    switch (move) {
      case DropMove(to: final to):
        final index = to.rank * 3 + to.file;
        if (index < 0 || index >= 9 || position.cells[index] != null) {
          throw ArgumentError('Illegal move $move for $position');
        }
        final cells = List<Side?>.of(position.cells);
        cells[index] = position.sideToMove;
        return position.copyWith(
          cells: cells,
          sideToMove: position.sideToMove.opponent,
        );
      case ResignMove(side: final side):
        return position.copyWith(resignedBy: side);
      case BoardMove():
      case PassMove():
        throw ArgumentError('Tic-tac-toe has no board moves or passes: $move');
    }
  }

  @override
  GameResult result(TicTacToePosition position, {List<TicTacToePosition> history = const []}) {
    if (position.resignedBy != null) {
      return GameResult.win(position.resignedBy!.opponent, WinReason.resignation);
    }
    for (final line in _lines) {
      final a = position.cells[line[0]];
      if (a != null &&
          a == position.cells[line[1]] &&
          a == position.cells[line[2]]) {
        // Not a real WinReason use case — tic-tac-toe is a fixture, not a
        // Komovia game, and "three in a row" has no dedicated reason.
        return GameResult.win(a, WinReason.score);
      }
    }
    if (!position.cells.contains(null)) {
      return const GameResult.draw(WinReason.stalemate);
    }
    return GameResult.ongoing;
  }

  @override
  String encode(TicTacToePosition position) {
    final board = position.cells
        .map((s) => switch (s) {
              null => '.',
              Side.first => 'X',
              Side.second => 'O',
            })
        .join();
    final turn = position.sideToMove == Side.first ? 'X' : 'O';
    final resigned = switch (position.resignedBy) {
      null => '-',
      Side.first => 'X',
      Side.second => 'O',
    };
    return '$board|$turn|$resigned';
  }

  @override
  TicTacToePosition decode(String notation) {
    final parts = notation.split('|');
    if (parts.length != 3 || parts[0].length != 9) {
      throw FormatException('Invalid tic-tac-toe notation: $notation');
    }

    Side? parseCell(String c) => switch (c) {
          'X' => Side.first,
          'O' => Side.second,
          '.' => null,
          _ => throw FormatException('Invalid cell "$c" in: $notation'),
        };

    Side parseTurn(String c) => switch (c) {
          'X' => Side.first,
          'O' => Side.second,
          _ => throw FormatException('Invalid turn "$c" in: $notation'),
        };

    final cells = parts[0].split('').map(parseCell).toList();
    final turn = parseTurn(parts[1]);
    final resigned = parts[2] == '-' ? null : parseCell(parts[2]);
    return TicTacToePosition(cells: cells, sideToMove: turn, resignedBy: resigned);
  }
}
