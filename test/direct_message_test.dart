import 'package:komovia_core/komovia_core.dart';
import 'package:test/test.dart';

void main() {
  group('MessageThread', () {
    test('round-trips through toJson/fromJson', () {
      final thread = MessageThread(
        id: 'u1_u2',
        participantUids: ['u1', 'u2'],
        participantNames: {'u1': 'Alice', 'u2': 'Bob'},
        lastMessage: 'hi',
        lastMessageAt: DateTime.utc(2026, 1, 1),
        lastSenderUid: 'u1',
        unreadCount: {'u1': 0, 'u2': 1},
      );

      final restored = MessageThread.fromJson(thread.toJson());

      expect(restored.id, thread.id);
      expect(restored.participantUids, thread.participantUids);
      expect(restored.participantNames, thread.participantNames);
      expect(restored.lastMessage, thread.lastMessage);
      expect(restored.lastMessageAt, thread.lastMessageAt);
      expect(restored.lastSenderUid, thread.lastSenderUid);
      expect(restored.unreadCount, thread.unreadCount);
    });

    test('nullable fields round-trip as null when absent', () {
      final thread = MessageThread(
        id: 'u1_u2',
        participantUids: const ['u1', 'u2'],
        participantNames: const {},
        unreadCount: const {},
      );
      final restored = MessageThread.fromJson(thread.toJson());
      expect(restored.lastMessage, isNull);
      expect(restored.lastMessageAt, isNull);
      expect(restored.lastSenderUid, isNull);
    });

    test('otherUidFor/otherDisplayNameFor/unreadCountFor', () {
      final thread = MessageThread(
        id: 'u1_u2',
        participantUids: const ['u1', 'u2'],
        participantNames: const {'u1': 'Alice', 'u2': 'Bob'},
        unreadCount: const {'u2': 3},
      );
      expect(thread.otherUidFor('u1'), 'u2');
      expect(thread.otherDisplayNameFor('u1'), 'Bob');
      expect(thread.unreadCountFor('u2'), 3);
      expect(thread.unreadCountFor('u1'), 0);
    });
  });

  group('DirectMessage', () {
    test('round-trips through toJson/fromJson', () {
      final message = DirectMessage(
        id: 'm1',
        fromUid: 'u1',
        content: 'hello',
        sentAt: DateTime.utc(2026, 1, 1, 12),
      );
      final restored = DirectMessage.fromJson(message.toJson());
      expect(restored.id, message.id);
      expect(restored.fromUid, message.fromUid);
      expect(restored.content, message.content);
      expect(restored.sentAt, message.sentAt);
    });
  });
}
