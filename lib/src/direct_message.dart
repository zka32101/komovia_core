/// A 1:1 message thread between two users, and a single message within it —
/// game-agnostic, like [AppNotification]/[Friendship].
///
/// Plain Dart data classes with no storage dependency; each game app's own
/// messaging service (Firestore today) converts to/from this shape at its
/// own storage boundary.
///
/// Ported from `zka32101/goen`'s `MessageThread`/`DirectMessage`
/// (`lib/models/direct_message.dart`), dropping the direct
/// `DocumentSnapshot`/`Timestamp` coupling the same way `AppNotification`
/// already did.
class MessageThread {
  final String id;

  /// Always exactly 2 uids today (no group chat support).
  final List<String> participantUids;

  /// uid -> display name, denormalized for display without a second lookup.
  final Map<String, String> participantNames;

  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String? lastSenderUid;

  /// uid -> unread count for that participant.
  final Map<String, int> unreadCount;

  const MessageThread({
    required this.id,
    required this.participantUids,
    required this.participantNames,
    this.lastMessage,
    this.lastMessageAt,
    this.lastSenderUid,
    required this.unreadCount,
  });

  /// The other participant's uid (no group chat, so there is exactly one).
  String otherUidFor(String myUid) {
    return participantUids.firstWhere((uid) => uid != myUid, orElse: () => '');
  }

  String otherDisplayNameFor(String myUid) {
    return participantNames[otherUidFor(myUid)] ?? 'Unknown';
  }

  int unreadCountFor(String uid) => unreadCount[uid] ?? 0;

  Map<String, Object?> toJson() => {
    'id': id,
    'participantUids': participantUids,
    'participantNames': participantNames,
    'lastMessage': lastMessage,
    'lastMessageAt': lastMessageAt?.toIso8601String(),
    'lastSenderUid': lastSenderUid,
    'unreadCount': unreadCount,
  };

  factory MessageThread.fromJson(Map<String, Object?> json) {
    return MessageThread(
      id: json['id'] as String,
      participantUids: List<String>.from(
        json['participantUids'] as List? ?? const [],
      ),
      participantNames: Map<String, String>.from(
        (json['participantNames'] as Map?) ?? const {},
      ),
      lastMessage: json['lastMessage'] as String?,
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.parse(json['lastMessageAt'] as String)
          : null,
      lastSenderUid: json['lastSenderUid'] as String?,
      unreadCount: Map<String, int>.from(
        (json['unreadCount'] as Map?) ?? const {},
      ),
    );
  }
}

/// A single message inside a [MessageThread].
class DirectMessage {
  final String id;
  final String fromUid;
  final String content;
  final DateTime sentAt;

  const DirectMessage({
    required this.id,
    required this.fromUid,
    required this.content,
    required this.sentAt,
  });

  Map<String, Object?> toJson() => {
    'id': id,
    'fromUid': fromUid,
    'content': content,
    'sentAt': sentAt.toIso8601String(),
  };

  factory DirectMessage.fromJson(Map<String, Object?> json) {
    return DirectMessage(
      id: json['id'] as String,
      fromUid: json['fromUid'] as String,
      content: json['content'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
    );
  }
}
