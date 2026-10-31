/// A decorative border/frame that can surround a user's avatar icon,
/// shared by the Komovia sibling apps.
///
/// Unlike [AvatarIcon] (free, pick any preset) or [CosmeticItem] (board/
/// piece skins, free or paid via IAP/subscription), a frame is never
/// purchased — it's earned by playing (rank milestones, achievements,
/// tournament results, streaks, etc). This keeps the "earn cosmetics
/// through play" layer of the hybrid monetization model (see
/// `CosmeticItem`'s doc comment) completely free, with no IAP surface
/// at all.
///
/// Each app defines its own concrete frame catalog and its own unlock
/// conditions (a win-rate milestone in one app has nothing to do with a
/// kyu/dan rank in another), since those conditions are entirely
/// game-specific. This class only holds the generic display shape —
/// what a frame IS, not when a user gets one — the same Flutter/
/// Firebase-free boundary as every other `komovia_core` model. Each
/// app's own achievement/profile service tracks which frame ids a user
/// has unlocked (as a plain `Set<String>`) and persists it at its own
/// storage boundary.
class AvatarFrame {
  const AvatarFrame({
    required this.id,
    required this.name,
    this.tier = FrameTier.bronze,
  });

  /// Stable identifier, unique within one app's catalog. Never reuse or
  /// repurpose once shipped — see [AvatarIcon.id]'s same warning.
  final String id;

  /// Display name; callers localize separately (same convention as
  /// [AvatarIcon.label]).
  final String name;

  /// Rough rarity/prestige banding, for a default color/style when an
  /// app doesn't want to hand-design every frame's look individually.
  /// Purely cosmetic metadata — carries no gameplay meaning.
  final FrameTier tier;

  /// Whether [frameId] is in the given user's unlocked set.
  ///
  /// `null` (no frame selected) is always allowed — that's "no frame",
  /// not a specific frame to check ownership of. Any caller resolving a
  /// user's *selected* frame for display should already have fallen
  /// back to `null`/no-frame before reaching here if the selected id
  /// isn't actually unlocked (e.g. after losing a time-limited frame).
  static bool isUnlocked(String? frameId, Set<String> unlockedFrameIds) {
    if (frameId == null) return true;
    return unlockedFrameIds.contains(frameId);
  }
}

/// Rough rarity/prestige banding for a frame's default look. Purely
/// cosmetic — never gates anything itself; an app's own achievement
/// logic decides which frame id a milestone grants.
enum FrameTier { bronze, silver, gold, platinum }
