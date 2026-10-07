import 'package:komovia_core/komovia_core.dart';
import 'package:test/test.dart';

void main() {
  group('AppNotification', () {
    test('round-trips through toJson/fromJson', () {
      final notification = AppNotification(
        id: 'n1',
        uid: 'user-1',
        title: 'タイトル',
        body: '本文',
        data: {'gameId': 'g1'},
        type: 'game_invitation',
        isRead: false,
        createdAt: DateTime.utc(2026, 1, 1, 12),
        readAt: DateTime.utc(2026, 1, 2),
      );

      final restored = AppNotification.fromJson(notification.toJson());

      expect(restored.id, notification.id);
      expect(restored.uid, notification.uid);
      expect(restored.title, notification.title);
      expect(restored.body, notification.body);
      expect(restored.data, notification.data);
      expect(restored.type, notification.type);
      expect(restored.isRead, notification.isRead);
      expect(restored.createdAt, notification.createdAt);
      expect(restored.readAt, notification.readAt);
    });

    test('readAt is optional and round-trips as null', () {
      final notification = AppNotification(
        id: 'n2',
        uid: 'user-1',
        title: 't',
        body: 'b',
        type: 'friend_request',
        isRead: false,
        createdAt: DateTime.utc(2026, 1, 1),
      );

      final restored = AppNotification.fromJson(notification.toJson());
      expect(restored.readAt, isNull);
    });

    test('copyWith overrides only the given fields', () {
      final notification = AppNotification(
        id: 'n3',
        uid: 'user-1',
        title: 't',
        body: 'b',
        type: 'friend_request',
        isRead: false,
        createdAt: DateTime.utc(2026, 1, 1),
      );

      final read = notification.copyWith(
        isRead: true,
        readAt: DateTime.utc(2026, 1, 2),
      );

      expect(read.isRead, isTrue);
      expect(read.readAt, DateTime.utc(2026, 1, 2));
      expect(read.id, notification.id);
      expect(read.title, notification.title);
    });
  });

  group('NotificationPreference', () {
    test('allows everything by default', () {
      const pref = NotificationPreference();
      expect(pref.allows('friend_request'), isTrue);
      expect(pref.allows('game_invitation'), isTrue);
      expect(pref.allows('tournament_match'), isTrue);
      expect(pref.allows('achievement'), isTrue);
    });

    test('allNotifications=false overrides every individual toggle', () {
      const pref = NotificationPreference(allNotifications: false);
      expect(pref.allows('friend_request'), isFalse);
      expect(pref.allows('game_invitation'), isFalse);
    });

    test('a disabled category hides only that category', () {
      const pref = NotificationPreference(friendRequests: false);
      expect(pref.allows('friend_request'), isFalse);
      expect(pref.allows('game_invitation'), isTrue);
    });

    test('an unrecognized type defaults to shown (fail open)', () {
      const pref = NotificationPreference(
        friendRequests: false,
        gameInvitations: false,
        tournamentUpdates: false,
        achievements: false,
      );
      expect(pref.allows('some_future_type'), isTrue);
    });

    test('gameInvitations covers all 4 game-invite notification types', () {
      const pref = NotificationPreference(gameInvitations: false);
      for (final type in [
        'game_invitation',
        'pvp_challenge',
        'correspondence_game',
        'team_game',
      ]) {
        expect(pref.allows(type), isFalse, reason: type);
      }
    });

    test('round-trips through toJson/fromJson', () {
      const pref = NotificationPreference(
        friendRequests: false,
        achievements: false,
      );
      final restored = NotificationPreference.fromJson(pref.toJson());
      expect(restored.friendRequests, isFalse);
      expect(restored.achievements, isFalse);
      expect(restored.gameInvitations, isTrue);
      expect(restored.tournamentUpdates, isTrue);
    });

    test('fromJson defaults missing keys to true', () {
      final restored = NotificationPreference.fromJson(const {});
      expect(restored.allNotifications, isTrue);
      expect(restored.friendRequests, isTrue);
    });
  });
}
