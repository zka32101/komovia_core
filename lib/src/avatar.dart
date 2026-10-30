/// Shared preset-avatar-icon catalog for the Komovia app family.
///
/// Each app stores only an avatar's [AvatarIcon.id] string on its own User
/// model (so this catalog can grow without a data migration) and resolves
/// it back to a display icon via [avatarIconById] wherever a profile is
/// shown (home screen, friends list, leaderboard, etc). An unknown or
/// missing id (including every user who existed before this feature)
/// falls back to [defaultAvatarIcon] rather than throwing, so this is
/// always safe to call on old data.
class AvatarIcon {
  const AvatarIcon({
    required this.id,
    required this.emoji,
    required this.label,
  });

  /// Stable identifier persisted on the user's own profile document.
  /// Never reuse or repurpose an id once shipped — that would silently
  /// reassign a different icon to users who already picked the old one.
  final String id;

  /// The glyph actually rendered (an emoji, so no image asset or network
  /// fetch is needed on any platform).
  final String emoji;

  /// Short human-readable name, for an accessibility label or a tooltip
  /// in the picker grid. Callers localize this themselves (it is a plain
  /// English fallback key, not shown verbatim to end users).
  final String label;
}

/// The full set of preset avatars a user may choose from, in picker
/// display order. Intentionally broad/neutral (animals, nature, objects)
/// rather than game-specific, since this catalog is shared by all four
/// sibling apps (Go/Shogi/Chess/Reversi).
const List<AvatarIcon> kAvatarIcons = [
  AvatarIcon(id: 'fox', emoji: '🦊', label: 'Fox'),
  AvatarIcon(id: 'owl', emoji: '🦉', label: 'Owl'),
  AvatarIcon(id: 'panda', emoji: '🐼', label: 'Panda'),
  AvatarIcon(id: 'tiger', emoji: '🐯', label: 'Tiger'),
  AvatarIcon(id: 'turtle', emoji: '🐢', label: 'Turtle'),
  AvatarIcon(id: 'dragon', emoji: '🐉', label: 'Dragon'),
  AvatarIcon(id: 'crane', emoji: '🦢', label: 'Crane'),
  AvatarIcon(id: 'cat', emoji: '🐱', label: 'Cat'),
  AvatarIcon(id: 'wolf', emoji: '🐺', label: 'Wolf'),
  AvatarIcon(id: 'eagle', emoji: '🦅', label: 'Eagle'),
  AvatarIcon(id: 'octopus', emoji: '🐙', label: 'Octopus'),
  AvatarIcon(id: 'lion', emoji: '🦁', label: 'Lion'),
  AvatarIcon(id: 'bamboo', emoji: '🎋', label: 'Bamboo'),
  AvatarIcon(id: 'cherry-blossom', emoji: '🌸', label: 'Cherry Blossom'),
  AvatarIcon(id: 'maple-leaf', emoji: '🍁', label: 'Maple Leaf'),
  AvatarIcon(id: 'mountain', emoji: '🗻', label: 'Mountain'),
  AvatarIcon(id: 'wave', emoji: '🌊', label: 'Wave'),
  AvatarIcon(id: 'moon', emoji: '🌙', label: 'Moon'),
  AvatarIcon(id: 'star', emoji: '⭐', label: 'Star'),
  AvatarIcon(id: 'lightning', emoji: '⚡', label: 'Lightning'),
  AvatarIcon(id: 'fire', emoji: '🔥', label: 'Fire'),
  AvatarIcon(id: 'crown', emoji: '👑', label: 'Crown'),
  AvatarIcon(id: 'shield', emoji: '🛡️', label: 'Shield'),
  AvatarIcon(id: 'compass', emoji: '🧭', label: 'Compass'),
];

/// The id used for anyone who has never picked an avatar (including every
/// account that existed before this feature shipped).
const String defaultAvatarIconId = 'fox';

AvatarIcon get defaultAvatarIcon => avatarIconById(defaultAvatarIconId);

/// Looks up a preset by id, falling back to [defaultAvatarIcon] for a
/// null, empty, or unrecognized id. Never throws.
AvatarIcon avatarIconById(String? id) {
  if (id == null || id.isEmpty) return avatarIconById(defaultAvatarIconId);
  for (final icon in kAvatarIcons) {
    if (icon.id == id) return icon;
  }
  return kAvatarIcons.first;
}
