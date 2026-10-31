import 'package:komovia_core/komovia_core.dart';
import 'package:test/test.dart';

void main() {
  group('Friendship', () {
    test('round-trips through toJson/fromJson', () {
      final friendship = Friendship(
        uid: 'user-1',
        friendUid: 'user-2',
        displayName: '太郎',
        status: 'accepted',
        requestedBy: 'user-1',
        blockedBy: null,
        addedAt: DateTime.utc(2026, 1, 1),
        lastPlayedAt: DateTime.utc(2026, 1, 5),
      );

      final restored = Friendship.fromJson(friendship.toJson());

      expect(restored.uid, friendship.uid);
      expect(restored.friendUid, friendship.friendUid);
      expect(restored.displayName, friendship.displayName);
      expect(restored.status, friendship.status);
      expect(restored.requestedBy, friendship.requestedBy);
      expect(restored.blockedBy, friendship.blockedBy);
      expect(restored.addedAt, friendship.addedAt);
      expect(restored.lastPlayedAt, friendship.lastPlayedAt);
    });

    test('requestedBy/blockedBy/lastPlayedAt are optional and round-trip as null', () {
      final friendship = Friendship(
        uid: 'user-1',
        friendUid: 'user-2',
        displayName: '太郎',
        status: 'pending',
        addedAt: DateTime.utc(2026, 1, 1),
      );

      final restored = Friendship.fromJson(friendship.toJson());
      expect(restored.requestedBy, isNull);
      expect(restored.blockedBy, isNull);
      expect(restored.lastPlayedAt, isNull);
    });

    test('isPending/isAccepted/isBlocked reflect status', () {
      final base = Friendship(
        uid: 'u1',
        friendUid: 'u2',
        displayName: 'x',
        status: 'pending',
        addedAt: DateTime.utc(2026, 1, 1),
      );
      expect(base.isPending, isTrue);
      expect(base.isAccepted, isFalse);
      expect(base.isBlocked, isFalse);

      final accepted = base.copyWith(status: 'accepted');
      expect(accepted.isAccepted, isTrue);
      expect(accepted.isPending, isFalse);

      final blocked = base.copyWith(status: 'blocked');
      expect(blocked.isBlocked, isTrue);
    });

    test('wasRequestedBy identifies the original sender', () {
      final friendship = Friendship(
        uid: 'u1',
        friendUid: 'u2',
        displayName: 'x',
        status: 'pending',
        requestedBy: 'u1',
        addedAt: DateTime.utc(2026, 1, 1),
      );
      expect(friendship.wasRequestedBy('u1'), isTrue);
      expect(friendship.wasRequestedBy('u2'), isFalse);
    });

    test('copyWith overrides only the given fields', () {
      final friendship = Friendship(
        uid: 'u1',
        friendUid: 'u2',
        displayName: 'x',
        status: 'pending',
        requestedBy: 'u1',
        addedAt: DateTime.utc(2026, 1, 1),
      );

      final updated = friendship.copyWith(status: 'accepted');

      expect(updated.status, 'accepted');
      expect(updated.uid, friendship.uid);
      expect(updated.friendUid, friendship.friendUid);
      expect(updated.requestedBy, friendship.requestedBy);
    });

    test('copyWith can explicitly clear requestedBy/blockedBy/lastPlayedAt to null', () {
      final friendship = Friendship(
        uid: 'u1',
        friendUid: 'u2',
        displayName: 'x',
        status: 'blocked',
        requestedBy: 'u1',
        blockedBy: 'u2',
        addedAt: DateTime.utc(2026, 1, 1),
        lastPlayedAt: DateTime.utc(2026, 1, 2),
      );

      final cleared = friendship.copyWith(
        requestedBy: null,
        blockedBy: null,
        lastPlayedAt: null,
      );

      expect(cleared.requestedBy, isNull);
      expect(cleared.blockedBy, isNull);
      expect(cleared.lastPlayedAt, isNull);
      expect(cleared.status, friendship.status);
    });
  });
}
