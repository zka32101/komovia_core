/// Generic engine-correlation "fair play" signal.
///
/// Chess.com and lichess both compute this after a completed game: how
/// closely did the player's moves track what an engine would have played
/// (move-by-move "engine correlation"), flagged for a human to review when
/// it's suspiciously high - never an automatic verdict. That same shape of
/// signal applies to any Komovia game with a per-move engine-eval
/// comparison - chess has Stockfish (komovia_chess's ChessAnalysisService
/// already computes per-move centipawn-loss for its move-quality/accuracy
/// feature), go has Fuego, shogi could gain its own engine later - so the
/// *scoring* logic (given a sequence of per-move "how close to the
/// engine's best move was this" values, compute a suspicion score) lives
/// here, generalized from no one game in particular. What stays
/// app-specific: calling the engine itself, persisting the result, and any
/// moderator UI.
///
/// What actually distinguishes it from a strong human: a strong human
/// still has a non-zero, above-baseline average loss and real move-to-move
/// variance (different playing styles, opening prep that diverges from
/// "best", occasional time-pressure slips) - whereas engine-assisted play
/// tends to show very low average loss AND very low variance AND,
/// especially, sustains both across many moves. A short game with a clean
/// run is not a strong signal on its own (even a genuinely weak player can
/// get lucky, or just play a short forced sequence); a long game that
/// stays clean the whole way is. So the score is deliberately built from
/// three independent pieces - low mean loss, low variance, and a high rate
/// of landing on the engine's literal top choice - combined and then
/// scaled down for small samples, rather than any single cheap average.
///
/// IMPORTANT LIMITATION: every threshold/weight below is a reasonable
/// first-pass heuristic reasoned from how centipawn-loss distributions are
/// generally described (strong human players average well above zero loss
/// per move with real variance; engine-matching play clusters near zero
/// with little variance), not a detector calibrated against this family's
/// own real player data. Before this is used for anything beyond "flag for
/// a human to look at", it needs tuning against real game logs (known-fair
/// strong players vs. confirmed engine-assisted ones).
library;

import 'dart:math' as math;

/// Below this many analyzed moves, there simply isn't enough data to say
/// anything - a short, clean-looking game (a forced tactical sequence, a
/// quick opening trap) looks identical to genuine engine assistance with
/// this few samples, so the score is suppressed regardless of how clean
/// the moves were. 20 half-moves (~10 full moves per side) is roughly
/// "past the opening, into a real middlegame decision or two" for chess;
/// other games can pick their own analogous floor.
const int minMovesForFairPlaySignal = 20;

/// Full statistical weight is only given once a sample is this large;
/// between [minMovesForFairPlaySignal] and this, the score ramps up
/// linearly (see [_sampleSizeWeight]) rather than jumping straight to full
/// confidence the moment the floor is crossed. 60 half-moves is "a full,
/// decided game" rather than an early resignation/short draw.
const int movesForFullFairPlayConfidence = 60;

/// A move within this many centipawns of the engine's own best move
/// counts as "matched the engine's top choice" for [FairPlaySignal.topMoveMatchRate].
/// Not 0, because engines themselves report slightly different eval
/// numbers move-to-move from search-depth noise even when the human move
/// *was* objectively best - demanding an exact literal tie would undercount.
const double topMoveMatchCpTolerance = 10;

/// Typical average centipawn-loss baseline for a strong, genuinely human
/// game. [FairPlaySignal.meanCentipawnLoss] values well below this (near
/// 0) contribute strongly to suspicion; values at/above it contribute
/// essentially nothing. There is no universal "right" number here (it
/// depends on the pool of players this is run against) - this is a
/// starting point pending real calibration, see the file-level doc.
const double cleanMeanLossBaselineCp = 35;

/// Typical per-move centipawn-loss standard deviation baseline for a
/// genuinely human game - real play has real move-to-move variance (some
/// moves obvious, some genuinely hard); engine-assisted play tends to
/// compress this toward zero. Same calibration caveat as
/// [cleanMeanLossBaselineCp].
const double cleanLossStdDevBaselineCp = 45;

/// Weight given to the "mean loss is suspiciously low" component of the
/// combined score. These three weights intentionally sum to 1.0.
const double fairPlayMeanLossWeight = 0.4;

/// Weight given to the "variance is suspiciously low" component.
const double fairPlayVarianceWeight = 0.3;

/// Weight given to the "rate of matching the engine's exact top move is
/// suspiciously high" component.
const double fairPlayTopMoveMatchWeight = 0.3;

/// [FairPlaySignal.suspicionScore] at/above this (0..100 scale) is
/// surfaced as [FairPlaySignal.reviewRecommended] - deliberately a high
/// bar (this is meant to be a rare flag worth a human's time, not a
/// routine one), chosen as a first pass pending real tuning.
const double fairPlayReviewThreshold = 70;

/// A flag-for-human-review signal only - **never** an automated verdict.
/// Nothing in this type or the function that produces it should be read
/// as "this player cheated"; [reviewRecommended] means exactly what its
/// name says, that the pattern is unusual enough to be worth a human
/// moderator's look, nothing stronger.
class FairPlaySignal {
  const FairPlaySignal({
    required this.sampleSize,
    required this.meanCentipawnLoss,
    required this.stdDevCentipawnLoss,
    required this.topMoveMatchRate,
    required this.suspicionScore,
    required this.reviewRecommended,
  });

  /// Number of per-move loss values the signal was computed from.
  final int sampleSize;

  /// Mean of the input centipawn-loss values. 0 for an empty input.
  final double meanCentipawnLoss;

  /// Population standard deviation of the input values. 0 for an input
  /// of size 0 or 1 (no variance is defined/meaningful with <2 samples).
  final double stdDevCentipawnLoss;

  /// Fraction (0..1) of moves within [topMoveMatchCpTolerance] of the
  /// engine's own best move for that position - i.e. effectively played
  /// the engine's exact top choice.
  final double topMoveMatchRate;

  /// Combined suspicion score, 0..100. Higher = more unusual (lower
  /// loss, lower variance, higher top-move-match rate), already scaled
  /// down for small [sampleSize] - see [FairPlaySignal] and the
  /// file-level doc for what this is and, critically, is not.
  final double suspicionScore;

  /// True when [suspicionScore] clears [fairPlayReviewThreshold] AND
  /// [sampleSize] clears [minMovesForFairPlaySignal] - a short game can
  /// never set this, no matter how clean it looks (see
  /// [minMovesForFairPlaySignal]'s doc).
  final bool reviewRecommended;

  /// The "nothing to see here" signal for when there isn't enough data
  /// at all (e.g. an empty move list).
  static const empty = FairPlaySignal(
    sampleSize: 0,
    meanCentipawnLoss: 0,
    stdDevCentipawnLoss: 0,
    topMoveMatchRate: 0,
    suspicionScore: 0,
    reviewRecommended: false,
  );
}

/// How much weight to give a sample of [sampleSize] moves, ramping
/// linearly from 0 at [minMovesForFairPlaySignal] up to 1 at
/// [movesForFullFairPlayConfidence] - a long clean game is a much
/// stronger signal than a short one even at the same raw stats, and this
/// is what makes that true: the raw combined score below is always
/// multiplied by this weight.
double _sampleSizeWeight(int sampleSize) {
  if (sampleSize < minMovesForFairPlaySignal) return 0;
  if (sampleSize >= movesForFullFairPlayConfidence) return 1;
  const span = movesForFullFairPlayConfidence - minMovesForFairPlaySignal;
  return (sampleSize - minMovesForFairPlaySignal) / span;
}

/// Clamps [value] into the closed interval \[0, 1\].
double _unit(double value) => value < 0 ? 0 : (value > 1 ? 1 : value);

/// Computes a [FairPlaySignal] from a sequence of per-move centipawn-loss
/// values (each >= 0, same convention as komovia_chess's
/// `MoveAnalysis.centipawnLoss`/komovia_core's `MoveAnalysis.loss`: how
/// much worse the position got for the side who played, relative to the
/// engine's own best move in that position - 0 means the engine's top
/// choice was played). Order within [centipawnLosses] doesn't matter to
/// this calculation (it's a distribution summary, not a sequence
/// analysis), so callers can pass losses for one side's moves in any
/// order - typically filtered to one side's own moves from a full game's
/// per-move analysis.
///
/// See the file-level doc for the overall design and its limitations.
/// This never returns anything claiming a verdict - only
/// [FairPlaySignal.reviewRecommended], which this function's own doc (and
/// [FairPlaySignal]'s) makes clear is a "worth a look" flag, not a
/// finding.
FairPlaySignal computeFairPlaySignal(List<double> centipawnLosses) {
  final n = centipawnLosses.length;
  if (n == 0) return FairPlaySignal.empty;

  final mean = centipawnLosses.reduce((a, b) => a + b) / n;

  double variance = 0;
  if (n > 1) {
    final sumSquaredDiff = centipawnLosses
        .map((v) => (v - mean) * (v - mean))
        .reduce((a, b) => a + b);
    variance = sumSquaredDiff / n;
  }
  final stdDev = variance <= 0 ? 0.0 : math.sqrt(variance);

  final topMoveMatches =
      centipawnLosses.where((v) => v <= topMoveMatchCpTolerance).length;
  final topMoveMatchRate = topMoveMatches / n;

  if (n == 1) {
    // A single move has no meaningful variance and is far below
    // [minMovesForFairPlaySignal] regardless - short-circuit to the
    // weighted-zero outcome without doing the (trivially degenerate)
    // combination math below.
    return FairPlaySignal(
      sampleSize: n,
      meanCentipawnLoss: mean,
      stdDevCentipawnLoss: 0,
      topMoveMatchRate: topMoveMatchRate,
      suspicionScore: 0,
      reviewRecommended: false,
    );
  }

  final lowLossSignal = _unit(1 - (mean / cleanMeanLossBaselineCp));
  final lowVarianceSignal = _unit(1 - (stdDev / cleanLossStdDevBaselineCp));
  final topMatchSignal = _unit(topMoveMatchRate);

  final combined = (lowLossSignal * fairPlayMeanLossWeight) +
      (lowVarianceSignal * fairPlayVarianceWeight) +
      (topMatchSignal * fairPlayTopMoveMatchWeight);

  final suspicionScore = combined * 100 * _sampleSizeWeight(n);

  return FairPlaySignal(
    sampleSize: n,
    meanCentipawnLoss: mean,
    stdDevCentipawnLoss: stdDev,
    topMoveMatchRate: topMoveMatchRate,
    suspicionScore: suspicionScore,
    reviewRecommended: n >= minMovesForFairPlaySignal &&
        suspicionScore >= fairPlayReviewThreshold,
  );
}
