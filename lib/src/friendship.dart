/// A friendship relationship between two users (one side of it — see
/// [status] below), game-agnostic.
///
/// Like [AppNotification], this is a plain Dart data class with no
/// storage dependency; each game app's own friend service (Firestore
/// today) converts to/from this shape at its own storage boundary.
///
/// Ported from `zka32101/goen`'s `Friend` — but following the *service's*
/// actual field shape (`lib/services/friend_service.dart`), not the
/// stale `lib/models/friend.dart` model file, which still had an old
/// `isBlocked: bool` field the service had already moved away from to
/// `status`/`requestedBy`/`blockedBy` (see goen's own 2026-10-01 friend
/// request/block bug-fix history). Porting the stale shape here would
/// have reproduced the same bug class komovia_core is meant to avoid.
///
/// A friendship is denormalized onto both users' own relationship
/// entries (`uid`'s entry and `friendUid`'s entry), which can disagree
/// transiently (e.g. a pending request only has an entry on the
/// recipient's side until accepted) — each [Friendship] value is one
/// side of that relationship, not a single shared record.
class Friendship {
  /// The user this relationship entry belongs to.
  final String uid;

  /// The other party.
  final String friendUid;

  /// Display name of [friendUid], denormalized for display without a
  /// second lookup.
  final String displayName;

  /// `'pending'`, `'accepted'`, or `'blocked'`.
  final String status;

  /// Who originally sent the friend request this relationship started
  /// from. Preserved across a resend; used to distinguish an incoming
  /// request (show accept/decline) from one the viewer sent themselves
  /// (show cancel) — see goen's own bug history for why this matters.
  /// Null for relationships predating this field.
  final String? requestedBy;

  /// Who caused [status] to become `'blocked'`. Used so that unblocking
  /// only undoes a block this side actually caused, never a block the
  /// other party placed independently. Null unless `status == 'blocked'`.
  final String? blockedBy;

  final DateTime addedAt;
  final DateTime? lastPlayedAt;

  const Friendship({
    required this.uid,
    required this.friendUid,
    required this.displayName,
    required this.status,
    this.requestedBy,
    this.blockedBy,
    required this.addedAt,
    this.lastPlayedAt,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isBlocked => status == 'blocked';

  /// For a pending request, whether [viewerUid] is the one who sent it
  /// (as opposed to the recipient, who should see accept/decline).
  bool wasRequestedBy(String viewerUid) => requestedBy == viewerUid;

  Friendship copyWith({
    String? uid,
    String? friendUid,
    String? displayName,
    String? status,
    Object? requestedBy = _unset,
    Object? blockedBy = _unset,
    DateTime? addedAt,
    Object? lastPlayedAt = _unset,
  }) {
    return Friendship(
      uid: uid ?? this.uid,
      friendUid: friendUid ?? this.friendUid,
      displayName: displayName ?? this.displayName,
      status: status ?? this.status,
      requestedBy:
          requestedBy == _unset ? this.requestedBy : requestedBy as String?,
      blockedBy: blockedBy == _unset ? this.blockedBy : blockedBy as String?,
      addedAt: addedAt ?? this.addedAt,
      lastPlayedAt: lastPlayedAt == _unset
          ? this.lastPlayedAt
          : lastPlayedAt as DateTime?,
    );
  }

  Map<String, Object?> toJson() => {
    'uid': uid,
    'friendUid': friendUid,
    'displayName': displayName,
    'status': status,
    'requestedBy': requestedBy,
    'blockedBy': blockedBy,
    'addedAt': addedAt.toIso8601String(),
    'lastPlayedAt': lastPlayedAt?.toIso8601String(),
  };

  factory Friendship.fromJson(Map<String, Object?> json) {
    return Friendship(
      uid: json['uid'] as String,
      friendUid: json['friendUid'] as String,
      displayName: json['displayName'] as String,
      status: json['status'] as String,
      requestedBy: json['requestedBy'] as String?,
      blockedBy: json['blockedBy'] as String?,
      addedAt: DateTime.parse(json['addedAt'] as String),
      lastPlayedAt: json['lastPlayedAt'] != null
          ? DateTime.parse(json['lastPlayedAt'] as String)
          : null,
    );
  }
}

/// Sentinel used by [Friendship.copyWith] to distinguish "not passed"
/// from an explicit `null`, so a nullable field can actually be cleared.
const Object _unset = Object();
