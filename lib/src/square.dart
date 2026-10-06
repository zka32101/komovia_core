/// A board coordinate, zero-indexed from the top-left corner.
///
/// [file] is the column (x-axis) and [rank] is the row (y-axis). Board
/// dimensions are defined by each [Game] implementation (shogi 9x9, go
/// 9/13/19, chess 8x8) — this class carries no bounds of its own.
class Square {
  final int file;
  final int rank;

  const Square(this.file, this.rank);

  @override
  bool operator ==(Object other) =>
      other is Square && other.file == file && other.rank == rank;

  @override
  int get hashCode => Object.hash(file, rank);

  @override
  String toString() => 'Square($file, $rank)';
}
