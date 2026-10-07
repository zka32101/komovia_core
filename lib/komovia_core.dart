/// Komovia common game infrastructure: the Game/Engine/BoardRenderer/
/// GameRecord/Puzzle/HandicapRule interfaces shared by shogi, go, and chess
/// (and future board games), independent of any one game's rules or UI.
///
/// For the shared contract-test kit that every game package should run
/// against its own `Game` implementation, see
/// `package:komovia_core/testkit.dart`.
library;

export 'src/app_notification.dart';
export 'src/board_renderer.dart';
export 'src/engine.dart';
export 'src/friendship.dart';
export 'src/game.dart';
export 'src/game_record.dart';
export 'src/game_result.dart';
export 'src/handicap_rule.dart';
export 'src/move.dart';
export 'src/position.dart';
export 'src/puzzle.dart';
export 'src/side.dart';
export 'src/square.dart';
