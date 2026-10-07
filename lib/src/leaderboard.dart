/// A ranking entry for one user within a leaderboard period/type,
/// game-agnostic like [AppNotification]/[Friendship]/[MessageThread].
///
/// Plain Dart data class, no storage dependency. Ported from
/// `zka32101/goen`'s `LeaderboardEntry` (`lib/models/leaderboard.dart`) —
/// the service's actual shape (`uid`/`rank`/`rating`/...), not the
/// differently-shaped, dead `LeaderboardEntry` freezed class also present
/// in `extended_game_models.dart` which nothing in the real service uses
/// (see goen's own barrel-export-collision bugfix history for this exact
/// confusion).
class LeaderboardEntry {
  final String uid;
  final String displayName;
  final int rank;
  final int rating;
  final int gamesPlayed;
  final int wins;
  final double winRate;
  final int puzzlesSolved;
  final int achievementsUnlocked;
  final int tournamentWins;
  final DateTime lastUpdated;

  const LeaderboardEntry({
    required this.uid,
    required this.displayName,
    required this.rank,
    required this.rating,
    required this.gamesPlayed,
    required this.wins,
    required this.winRate,
    required this.puzzlesSolved,
    this.achievementsUnlocked = 0,
    this.tournamentWins = 0,
    required this.lastUpdated,
  });

  LeaderboardEntry copyWith({
    String? uid,
    String? displayName,
    int? rank,
    int? rating,
    int? gamesPlayed,
    int? wins,
    double? winRate,
    int? puzzlesSolved,
    int? achievementsUnlocked,
    int? tournamentWins,
    DateTime? lastUpdated,
  }) {
    return LeaderboardEntry(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      rank: rank ?? this.rank,
      rating: rating ?? this.rating,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      wins: wins ?? this.wins,
      winRate: winRate ?? this.winRate,
      puzzlesSolved: puzzlesSolved ?? this.puzzlesSolved,
      achievementsUnlocked: achievementsUnlocked ?? this.achievementsUnlocked,
      tournamentWins: tournamentWins ?? this.tournamentWins,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, Object?> toJson() => {
    'uid': uid,
    'displayName': displayName,
    'rank': rank,
    'rating': rating,
    'gamesPlayed': gamesPlayed,
    'wins': wins,
    'winRate': winRate,
    'puzzlesSolved': puzzlesSolved,
    'achievementsUnlocked': achievementsUnlocked,
    'tournamentWins': tournamentWins,
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  factory LeaderboardEntry.fromJson(Map<String, Object?> json) {
    return LeaderboardEntry(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String? ?? 'Anonymous',
      rank: json['rank'] as int? ?? 0,
      rating: json['rating'] as int? ?? 1200,
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      winRate: (json['winRate'] as num?)?.toDouble() ?? 0.0,
      puzzlesSolved: json['puzzlesSolved'] as int? ?? 0,
      achievementsUnlocked: json['achievementsUnlocked'] as int? ?? 0,
      tournamentWins: json['tournamentWins'] as int? ?? 0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
    );
  }

  @override
  String toString() =>
      'LeaderboardEntry(rank: $rank, displayName: $displayName, rating: $rating)';
}

/// How often a leaderboard resets/aggregates.
enum LeaderboardPeriod {
  daily,
  weekly,
  monthly,
  allTime;

  String toShortString() {
    switch (this) {
      case LeaderboardPeriod.daily:
        return 'daily';
      case LeaderboardPeriod.weekly:
        return 'weekly';
      case LeaderboardPeriod.monthly:
        return 'monthly';
      case LeaderboardPeriod.allTime:
        return 'all_time';
    }
  }

  static LeaderboardPeriod fromString(String value) {
    switch (value) {
      case 'daily':
        return LeaderboardPeriod.daily;
      case 'weekly':
        return LeaderboardPeriod.weekly;
      case 'monthly':
        return LeaderboardPeriod.monthly;
      case 'all_time':
        return LeaderboardPeriod.allTime;
      default:
        return LeaderboardPeriod.allTime;
    }
  }
}

/// What a leaderboard ranks by.
enum LeaderboardType {
  rating,
  puzzles,
  achievements,
  tournament;

  String toShortString() {
    switch (this) {
      case LeaderboardType.rating:
        return 'rating';
      case LeaderboardType.puzzles:
        return 'puzzles';
      case LeaderboardType.achievements:
        return 'achievements';
      case LeaderboardType.tournament:
        return 'tournament';
    }
  }

  static LeaderboardType fromString(String value) {
    switch (value) {
      case 'rating':
        return LeaderboardType.rating;
      case 'puzzles':
        return LeaderboardType.puzzles;
      case 'achievements':
        return LeaderboardType.achievements;
      case 'tournament':
        return LeaderboardType.tournament;
      default:
        return LeaderboardType.rating;
    }
  }
}
