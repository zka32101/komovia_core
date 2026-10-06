/// Which side is to move, or has moved.
///
/// Generic across shogi (先手/後手), go (black/white), and chess
/// (white/black) — each game package maps its own vocabulary onto
/// [first]/[second] rather than komovia_core knowing any of them.
enum Side {
  first,
  second;

  /// The other side.
  Side get opponent => this == Side.first ? Side.second : Side.first;
}
