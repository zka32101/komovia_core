import 'side.dart';

enum ResultKind { ongoing, win, draw }

/// Why a game ended (or, for [ongoing], not applicable).
enum WinReason {
  checkmate,
  resignation,
  timeout,
  illegalMove,

  /// 千日手 (shogi/chess threefold repetition).
  repetition,

  /// 持将棋 (shogi impasse — both kings have entered the enemy camp).
  impasse,

  /// Area/territory count (go).
  score,
  stalemate,
  agreement,
}

/// The outcome of a [Position]: still being played, decisively won, or
/// drawn.
class GameResult {
  final ResultKind kind;
  final Side? winner;
  final WinReason? reason;

  const GameResult._(this.kind, this.winner, this.reason);

  static const GameResult ongoing =
      GameResult._(ResultKind.ongoing, null, null);

  const GameResult.win(Side winner, WinReason reason)
      : this._(ResultKind.win, winner, reason);

  const GameResult.draw(WinReason reason)
      : this._(ResultKind.draw, null, reason);

  bool get isOngoing => kind == ResultKind.ongoing;

  @override
  bool operator ==(Object other) =>
      other is GameResult &&
      other.kind == kind &&
      other.winner == winner &&
      other.reason == reason;

  @override
  int get hashCode => Object.hash(kind, winner, reason);

  @override
  String toString() => switch (kind) {
        ResultKind.ongoing => 'GameResult.ongoing',
        ResultKind.win => 'GameResult.win($winner, $reason)',
        ResultKind.draw => 'GameResult.draw($reason)',
      };
}
