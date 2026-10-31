/// Komovia common game infrastructure: the Game/Engine/BoardRenderer/
/// GameRecord/Puzzle/HandicapRule interfaces shared by shogi, go, and chess
/// (and future board games), independent of any one game's rules or UI.
///
/// For the shared contract-test kit that every game package should run
/// against its own `Game` implementation, see
/// `package:komovia_core/testkit.dart`.
library;

export 'src/ad_gate.dart';
export 'src/app_notification.dart';
export 'src/avatar.dart';
export 'src/board_renderer.dart';
export 'src/clock.dart';
export 'src/cosmetic_item.dart';
export 'src/daily_streak.dart';
export 'src/direct_message.dart';
export 'src/engine.dart';
export 'src/entitlement.dart';
export 'src/event_window.dart';
export 'src/fair_play.dart';
export 'src/friendship.dart';
export 'src/game.dart';
export 'src/game_record.dart';
export 'src/game_result.dart';
export 'src/handicap_rule.dart';
export 'src/leaderboard.dart';
export 'src/matchmaking.dart';
export 'src/move.dart';
export 'src/onboarding.dart';
export 'src/position.dart';
export 'src/promoted_app.dart';
export 'src/puzzle.dart';
export 'src/rating.dart';
export 'src/review.dart';
export 'src/shareable_moment.dart';
export 'src/side.dart';
export 'src/square.dart';
export 'src/tournament.dart';
