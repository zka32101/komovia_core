/// Game-agnostic Elo-style rating math, shared by every Komovia app's
/// "growth tracking" / AI-strength-rating feature (go/shogi/chess/reversi
/// all offer a discrete AI difficulty level and want a single-player
/// rating number that goes up for beating a stronger opponent and down
/// for losing to a weaker one).
///
/// Ported from `komovia_go`'s `lib/utils/ai_rating.dart` — this is the
/// generalized form of that file's `computeRatingDelta`/
/// `opponentRatingForAiLevel`, with the app-specific `GameResult` enum
/// replaced by a plain `score` (1.0 win / 0.5 draw / 0.0 loss), since each
/// app's own result enum differs (and `game_result.dart`'s `GameResult`
/// here is the richer win/draw/ongoing+reason shape used for game logic,
/// not a simple 3-outcome AI-game record).
library;

import 'dart:math' as math;

/// Standard Elo rating delta for one game.
///
/// [score] is from the rated player's own perspective: `1.0` for a win,
/// `0.5` for a draw, `0.0` for a loss (including resignation). Returns the
/// signed point change to add to [currentRating].
///
/// [kFactor] controls the maximum swing per game; Komovia apps use `24`
/// (deliberately higher than chess's usual 16-32 floor) so a new player's
/// rating visibly moves within just a handful of games - part of the
/// "feel your growth" product concept, not a competitive-integrity choice.
int computeEloDelta({
  required int currentRating,
  required int opponentRating,
  required double score,
  int kFactor = 24,
}) {
  final expected =
      1 / (1 + math.pow(10, (opponentRating - currentRating) / 400));
  return (kFactor * (score - expected)).round();
}

/// Maps a discrete AI difficulty level onto the same rating scale
/// [computeEloDelta] operates on, for games whose AI only exposes a
/// numbered strength level (not its own numeric rating).
///
/// [level] is clamped to `[minLevel, maxLevel]`. [baseLevel] is the level
/// whose virtual rating equals [baseRating] exactly; every level away
/// from it shifts the virtual rating by [step]. Each app picks its own
/// `baseLevel`/`step` to match its own AI's actual level range and feel
/// (komovia_go: `minLevel: 1, maxLevel: 10, baseLevel: 5, step: 150`, so
/// level 10 maps to 1950 and level 1 to 600).
int ratingForAiLevel({
  required int level,
  required int minLevel,
  required int maxLevel,
  required int baseLevel,
  int baseRating = 1200,
  int step = 150,
}) {
  final clamped = level.clamp(minLevel, maxLevel);
  return baseRating + (clamped - baseLevel) * step;
}
