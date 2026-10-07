/// An in-app notification (friend request, game invitation, tournament
/// pairing, etc.), game-agnostic by design.
///
/// This is deliberately a plain Dart data class — no `cloud_firestore`
/// dependency — to keep komovia_core Flutter/Firebase-free. Each game
/// package's own notification service (backed by whatever storage it
/// uses — Firestore today) is responsible for converting to/from this
/// shape at its own storage boundary, the same way `Game.encode/decode`
/// keeps komovia_core's `Position` free of any one notation.
///
/// Ported from `zka32101/goen`'s `AppNotification` (`lib/models/
/// notification.dart`), generalized by dropping the direct
/// `DocumentSnapshot`/`Timestamp` coupling. First of several social/
/// service models being extracted into komovia_core per the common
/// basis design doc's §3-2 (段階3: サービス共通化) — see also
/// `Friend`/`DirectMessage`/`Tournament`/`LeaderboardEntry`, planned as
/// follow-up extractions.
class AppNotification {
  final String id;
  final String uid;
  final String title;
  final String body;

  /// Free-form payload for the notification's target (e.g. a game id, a
  /// tournament match id). Interpreted by whichever screen routes the
  /// notification tap — komovia_core doesn't know what's in it.
  final Map<String, Object?>? data;

  /// e.g. `'friend_request'`, `'game_invitation'`, `'tournament_match'`.
  /// Not an enum: the set of notification types is open-ended and
  /// defined by each game/app, not by komovia_core.
  final String type;

  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  const AppNotification({
    required this.id,
    required this.uid,
    required this.title,
    required this.body,
    this.data,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  AppNotification copyWith({
    String? id,
    String? uid,
    String? title,
    String? body,
    Map<String, Object?>? data,
    String? type,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  /// Round-trips through plain JSON-compatible values (`DateTime` as
  /// ISO8601 strings) — storage-agnostic, unlike `goen`'s original
  /// `toFirestore`/`fromFirestore` (which stored `Timestamp` directly).
  Map<String, Object?> toJson() => {
    'id': id,
    'uid': uid,
    'title': title,
    'body': body,
    'data': data,
    'type': type,
    'isRead': isRead,
    'createdAt': createdAt.toIso8601String(),
    'readAt': readAt?.toIso8601String(),
  };

  factory AppNotification.fromJson(Map<String, Object?> json) {
    return AppNotification(
      id: json['id'] as String,
      uid: json['uid'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      data: (json['data'] as Map<String, Object?>?),
      type: json['type'] as String,
      isRead: json['isRead'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
    );
  }
}

/// Per-category opt-in/out for notifications, shared across games.
///
/// The category set mirrors what `goen`'s `NotificationPreference`
/// already distinguished (friend requests, game invitations, tournament
/// updates, achievements) — all of which are game-agnostic concepts.
class NotificationPreference {
  final bool allNotifications;
  final bool friendRequests;
  final bool gameInvitations;
  final bool tournamentUpdates;
  final bool achievements;

  const NotificationPreference({
    this.allNotifications = true,
    this.friendRequests = true,
    this.gameInvitations = true,
    this.tournamentUpdates = true,
    this.achievements = true,
  });

  /// Whether a notification of [type] should be shown, given this
  /// preference. An unrecognized [type] defaults to shown (fail open —
  /// see `goen`'s own 2026-10-01 notification-preference fix).
  bool allows(String type) {
    if (!allNotifications) return false;
    switch (type) {
      case 'friend_request':
        return friendRequests;
      case 'game_invitation':
      case 'pvp_challenge':
      case 'correspondence_game':
      case 'team_game':
        return gameInvitations;
      case 'tournament_match':
        return tournamentUpdates;
      case 'achievement':
        return achievements;
      default:
        return true;
    }
  }

  Map<String, Object?> toJson() => {
    'allNotifications': allNotifications,
    'friendRequests': friendRequests,
    'gameInvitations': gameInvitations,
    'tournamentUpdates': tournamentUpdates,
    'achievements': achievements,
  };

  factory NotificationPreference.fromJson(Map<String, Object?> json) {
    return NotificationPreference(
      allNotifications: json['allNotifications'] as bool? ?? true,
      friendRequests: json['friendRequests'] as bool? ?? true,
      gameInvitations: json['gameInvitations'] as bool? ?? true,
      tournamentUpdates: json['tournamentUpdates'] as bool? ?? true,
      achievements: json['achievements'] as bool? ?? true,
    );
  }
}
