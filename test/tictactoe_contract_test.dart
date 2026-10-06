import 'package:komovia_core/testkit.dart';

import 'fixtures/tictactoe/tictactoe_game.dart';
import 'fixtures/tictactoe/tictactoe_position.dart';

/// Proves the Game/Move/Position/GameResult interfaces are actually
/// implementable, and that `runGameContractTests` catches what it should,
/// by running it against the tic-tac-toe fixture (see
/// [TicTacToePosition] for why tic-tac-toe).
void main() {
  final game = TicTacToeGame();

  runGameContractTests<TicTacToePosition>(
    game,
    samplePosition: () => game.apply(
      game.initialPosition(),
      game.legalMoves(game.initialPosition()).first,
    ),
  );
}
