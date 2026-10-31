/// A tournament, its participants, and its bracket matches —
/// game-agnostic (any game played via `PvpGame`-style matches can use
/// this), like [AppNotification]/[Friendship]/[MessageThread]/
/// [LeaderboardEntry].
///
/// Plain Dart data classes, no storage dependency. Ported from
/// `zka32101/goen`'s `Tournament`/`TournamentParticipant`/
/// `TournamentMatch`/`TournamentStandingEntry` (`lib/models/
/// tournament.dart`).
class Tournament {
  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final int maxParticipants;

  /// `'single_elimination'`, `'round_robin'`, or `'swiss'`.
  final String format;

  /// `'upcoming'`, `'active'`, `'completed'`, or `'cancelled'`.
  final String status;

  final List<String> participantUids;
  final String? winnerId;

  /// The organizer's uid, set once at creation and treated as immutable
  /// afterward so a storage layer's access rules can restrict
  /// organizer-only operations (starting the tournament, etc.) to this
  /// uid. Null for tournaments created by an automated/admin process with
  /// no single human organizer.
  final String? createdBy;

  /// Board size used for matches (e.g. 9/13/19 for Go, irrelevant/fixed
  /// for a game with no variable board size).
  final int boardSize;

  /// The highest round number for which the next round has already been
  /// generated (0 = none yet). Internal bookkeeping a
  /// round-advancement routine uses to guard against double-generating a
  /// round when two match results land near-simultaneously.
  final int lastAdvancedRound;

  /// Whether this tournament was created by an automated recurring job
  /// rather than a human organizer.
  final bool isAutoWeekly;

  /// Swiss format only: the fixed number of rounds decided at tournament
  /// start from the participant count. 0 for single_elimination/
  /// round_robin, which don't need a fixed round count.
  final int totalRounds;

  final DateTime createdAt;

  const Tournament({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.maxParticipants,
    required this.format,
    required this.status,
    required this.participantUids,
    this.winnerId,
    this.createdBy,
    this.boardSize = 19,
    this.lastAdvancedRound = 0,
    this.isAutoWeekly = false,
    this.totalRounds = 0,
    required this.createdAt,
  });

  bool get isFull => participantUids.length >= maxParticipants;
  bool get isUpcoming => status == 'upcoming';
  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  Tournament copyWith({
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    int? maxParticipants,
    String? format,
    String? status,
    List<String>? participantUids,
    Object? winnerId = _unset,
    int? boardSize,
    int? lastAdvancedRound,
    bool? isAutoWeekly,
    int? totalRounds,
  }) {
    return Tournament(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      format: format ?? this.format,
      status: status ?? this.status,
      participantUids: participantUids ?? this.participantUids,
      winnerId: winnerId == _unset ? this.winnerId : winnerId as String?,
      createdBy: createdBy,
      boardSize: boardSize ?? this.boardSize,
      lastAdvancedRound: lastAdvancedRound ?? this.lastAdvancedRound,
      isAutoWeekly: isAutoWeekly ?? this.isAutoWeekly,
      totalRounds: totalRounds ?? this.totalRounds,
      createdAt: createdAt,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'maxParticipants': maxParticipants,
    'format': format,
    'status': status,
    'participantUids': participantUids,
    'winnerId': winnerId,
    'createdBy': createdBy,
    'boardSize': boardSize,
    'lastAdvancedRound': lastAdvancedRound,
    'isAutoWeekly': isAutoWeekly,
    'totalRounds': totalRounds,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Tournament.fromJson(Map<String, Object?> json) {
    return Tournament(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : DateTime.now(),
      maxParticipants: json['maxParticipants'] as int? ?? 0,
      format: json['format'] as String? ?? 'single_elimination',
      status: json['status'] as String? ?? 'upcoming',
      participantUids: List<String>.from(
        json['participantUids'] as List? ?? const [],
      ),
      winnerId: json['winnerId'] as String?,
      createdBy: json['createdBy'] as String?,
      boardSize: json['boardSize'] as int? ?? 19,
      lastAdvancedRound: json['lastAdvancedRound'] as int? ?? 0,
      isAutoWeekly: json['isAutoWeekly'] as bool? ?? false,
      totalRounds: json['totalRounds'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  @override
  String toString() => 'Tournament(id: $id, name: $name)';
}

const Object _unset = Object();

/// A single participant's standing within a [Tournament].
class TournamentParticipant {
  final String tournamentId;
  final String uid;
  final String displayName;
  final int? seed;
  final int? currentRound;
  final int? currentRanking;
  final DateTime joinedAt;

  const TournamentParticipant({
    required this.tournamentId,
    required this.uid,
    required this.displayName,
    this.seed,
    this.currentRound,
    this.currentRanking,
    required this.joinedAt,
  });

  Map<String, Object?> toJson() => {
    'tournamentId': tournamentId,
    'uid': uid,
    'displayName': displayName,
    'seed': seed,
    'currentRound': currentRound,
    'currentRanking': currentRanking,
    'joinedAt': joinedAt.toIso8601String(),
  };

  factory TournamentParticipant.fromJson(Map<String, Object?> json) {
    return TournamentParticipant(
      tournamentId: json['tournamentId'] as String? ?? '',
      uid: json['uid'] as String,
      displayName: json['displayName'] as String? ?? 'Player',
      seed: json['seed'] as int?,
      currentRound: json['currentRound'] as int?,
      currentRanking: json['currentRanking'] as int?,
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'] as String)
          : DateTime.now(),
    );
  }

  @override
  String toString() =>
      'TournamentParticipant(tournament: $tournamentId, uid: $uid)';
}

/// A single bracket match within a [Tournament].
class TournamentMatch {
  final String id;
  final String tournamentId;
  final String? player1Uid;
  final String? player1DisplayName;
  final String? player2Uid;
  final String? player2DisplayName;
  final int round;
  final String? winnerUid;

  /// `'pending'`, `'in_progress'`, or `'completed'`.
  final String status;

  /// The id of the game (e.g. a `PvpGame`) this match was played as, once
  /// one has been created.
  final String? gameId;

  final DateTime scheduledAt;
  final DateTime? completedAt;

  const TournamentMatch({
    required this.id,
    required this.tournamentId,
    this.player1Uid,
    this.player1DisplayName,
    this.player2Uid,
    this.player2DisplayName,
    required this.round,
    this.winnerUid,
    required this.status,
    this.gameId,
    required this.scheduledAt,
    this.completedAt,
  });

  /// A slot with no opponent (a bye).
  bool get isBye => player1Uid == null || player2Uid == null;

  bool get isPending => status == 'pending';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';

  Map<String, Object?> toJson() => {
    'id': id,
    'tournamentId': tournamentId,
    'player1Uid': player1Uid,
    'player1DisplayName': player1DisplayName,
    'player2Uid': player2Uid,
    'player2DisplayName': player2DisplayName,
    'round': round,
    'winnerUid': winnerUid,
    'status': status,
    'gameId': gameId,
    'scheduledAt': scheduledAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
  };

  factory TournamentMatch.fromJson(Map<String, Object?> json) {
    return TournamentMatch(
      id: json['id'] as String,
      tournamentId: json['tournamentId'] as String? ?? '',
      player1Uid: json['player1Uid'] as String?,
      player1DisplayName: json['player1DisplayName'] as String?,
      player2Uid: json['player2Uid'] as String?,
      player2DisplayName: json['player2DisplayName'] as String?,
      round: json['round'] as int? ?? 1,
      winnerUid: json['winnerUid'] as String?,
      status: json['status'] as String? ?? 'pending',
      gameId: json['gameId'] as String?,
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'] as String)
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  @override
  String toString() =>
      'TournamentMatch(id: $id, round: $round, status: $status)';
}

/// One row of a round-robin standings table, computed on demand from
/// completed matches (never persisted directly).
class TournamentStandingEntry {
  final String uid;
  final String displayName;
  final int wins;
  final int losses;

  const TournamentStandingEntry({
    required this.uid,
    required this.displayName,
    required this.wins,
    required this.losses,
  });

  int get played => wins + losses;
}
