import 'package:komovia_core/komovia_core.dart';
import 'package:test/test.dart';

void main() {
  group('AvatarFrame.isUnlocked', () {
    test('null frameId (no frame selected) is always allowed', () {
      expect(AvatarFrame.isUnlocked(null, {}), isTrue);
    });

    test('true when the id is in the unlocked set', () {
      expect(
          AvatarFrame.isUnlocked('gold_dan', {'gold_dan', 'streak_7'}), isTrue);
    });

    test('false when the id is not in the unlocked set', () {
      expect(AvatarFrame.isUnlocked('gold_dan', {'streak_7'}), isFalse);
      expect(AvatarFrame.isUnlocked('gold_dan', {}), isFalse);
    });
  });

  group('AvatarFrame construction', () {
    test('defaults to bronze tier', () {
      const frame = AvatarFrame(id: 'first_win', name: 'First Win');
      expect(frame.tier, FrameTier.bronze);
    });

    test('accepts an explicit tier', () {
      const frame =
          AvatarFrame(id: 'dan_9', name: '九段', tier: FrameTier.platinum);
      expect(frame.tier, FrameTier.platinum);
    });
  });
}
