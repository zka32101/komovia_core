import 'package:komovia_core/komovia_core.dart';
import 'package:test/test.dart';

void main() {
  group('kAvatarIcons', () {
    test('has no duplicate ids', () {
      final ids = kAvatarIcons.map((a) => a.id).toSet();
      expect(ids.length, kAvatarIcons.length);
    });

    test('is non-empty', () {
      expect(kAvatarIcons, isNotEmpty);
    });
  });

  group('avatarIconById', () {
    test('resolves a known id', () {
      final icon = avatarIconById('dragon');
      expect(icon.id, 'dragon');
      expect(icon.emoji, '🐉');
    });

    test('falls back to the default for null', () {
      expect(avatarIconById(null).id, defaultAvatarIconId);
    });

    test('falls back to the default for empty string', () {
      expect(avatarIconById('').id, defaultAvatarIconId);
    });

    test('falls back to the default for an unrecognized id', () {
      // Covers every pre-existing account from before this feature shipped.
      expect(avatarIconById('no-such-icon').id, defaultAvatarIconId);
    });
  });

  group('defaultAvatarIcon', () {
    test('is a real entry in the catalog', () {
      expect(kAvatarIcons.map((a) => a.id), contains(defaultAvatarIcon.id));
    });
  });
}
