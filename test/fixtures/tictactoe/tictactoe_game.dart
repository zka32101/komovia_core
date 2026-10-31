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
  Object positionKey(TicTacToePosition position) => encode(position);

  @override
  List<Move> legalMoves(
    TicTacToePosition position, {
    List<Object> historyKeys = const [],
  }) {
    // Tic-tac-toe's legality never depends on history; historyKeys is unused.
    if (!result(position).isOngoing) return const [];
    return [
      for (var i = 0; i < 9; i++)
        if (position.cells[i] == null)
          DropMove(pieceType: 'mark', to: Square(i % 3, i ~/ 3)),
    ];
  }

  @override
  TicTacToePosition apply(
    TicTacToePosition position,
    Move move, {
    List<Object> historyKeys = const [],
  }) {
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
  GameResult result(TicTacToePosition position, {List<Object> historyKeys = const []}) {
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

  // --- GameRecord <-> notation ---------------------------------------
  //
  // Not a real kifu format — just enough to prove Game.exportRecord /
  // importRecord round-trip for a fixture that only ever produces
  // DropMove and ResignMove. A real game's KIF/SGF/PGN codec lives in its
  // own package.

  @override
  String exportRecord(GameRecord record) {
    final lines = <String>[
      record.gameId,
      _encodeResult(record.result),
      for (final m in record.moves)
        '${m.number},${_sideChar(m.side)},${_encodeMove(m.move)}',
    ];
    return lines.join('\n');
  }

  @override
  GameRecord importRecord(String notation) {
    final lines = notation.split('\n');
    if (lines.length < 2 || lines[0] != id) {
      throw FormatException('Invalid tic-tac-toe record: $notation');
    }
    final result = _decodeResult(lines[1]);
    final moves = [
      for (final line in lines.skip(2))
        if (line.isNotEmpty) _decodeRecordedMove(line, notation),
    ];
    return GameRecord(gameId: lines[0], moves: moves, result: result);
  }

  static String _sideChar(Side s) => s == Side.first ? 'X' : 'O';
  static Side _parseSideChar(String c) => switch (c) {
        'X' => Side.first,
        'O' => Side.second,
        _ => throw FormatException('Invalid side "$c"'),
      };

  static String _encodeMove(Move m) => switch (m) {
        BoardMove(from: final f, to: final t, promote: final p) =>
          'B,${f.file},${f.rank},${t.file},${t.rank},${p ? 1 : 0}',
        DropMove(pieceType: final pt, to: final t) =>
          'D,$pt,${t.file},${t.rank}',
        PassMove() => 'P',
        ResignMove(side: final s) => 'R,${_sideChar(s)}',
      };

  static Move _decodeMove(List<String> t, String source) {
    if (t.isEmpty) throw FormatException('Empty move in: $source');
    switch (t[0]) {
      case 'B' when t.length == 6:
        return BoardMove(
          from: Square(int.parse(t[1]), int.parse(t[2])),
          to: Square(int.parse(t[3]), int.parse(t[4])),
          promote: t[5] == '1',
        );
      case 'D' when t.length == 4:
        return DropMove(pieceType: t[1], to: Square(int.parse(t[2]), int.parse(t[3])));
      case 'P' when t.length == 1:
        return const PassMove();
      case 'R' when t.length == 2:
        return ResignMove(_parseSideChar(t[1]));
      default:
        throw FormatException('Invalid move "${t.join(',')}" in: $source');
    }
  }

  static RecordedMove _decodeRecordedMove(String line, String source) {
    final parts = line.split(',');
    if (parts.length < 3) {
      throw FormatException('Invalid move line "$line" in: $source');
    }
    final number = int.tryParse(parts[0]);
    if (number == null) {
      throw FormatException('Invalid move number "${parts[0]}" in: $source');
    }
    return RecordedMove(
      number: number,
      side: _parseSideChar(parts[1]),
      move: _decodeMove(parts.sublist(2), source),
    );
  }

  static String _encodeResult(GameResult r) {
    final winner = r.winner == null ? '' : _sideChar(r.winner!);
    return '${r.kind.name},$winner,${r.reason?.name ?? ''}';
  }

  static GameResult _decodeResult(String s) {
    final parts = s.split(',');
    if (parts.length != 3) throw FormatException('Invalid result: $s');

    ResultKind? kind;
    for (final k in ResultKind.values) {
      if (k.name == parts[0]) kind = k;
    }
    if (kind == null) throw FormatException('Invalid result kind: $s');

    final winner = parts[1].isEmpty ? null : _parseSideChar(parts[1]);

    WinReason? reason;
    for (final w in WinReason.values) {
      if (w.name == parts[2]) reason = w;
    }
    if (parts[2].isNotEmpty && reason == null) {
      throw FormatException('Invalid win reason: $s');
    }

    return switch (kind) {
      ResultKind.ongoing => GameResult.ongoing,
      ResultKind.win => GameResult.win(winner!, reason!),
      ResultKind.draw => GameResult.draw(reason!),
    };
  }
}
