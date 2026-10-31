/// Shared, game-agnostic model for a purchasable visual cosmetic (board
/// skin, piece/stone set, etc), shared by the Komovia sibling apps.
///
/// Monetization model (confirmed with the user after a competitor
/// survey — see this package's commit history): no gacha, no paid
/// virtual currency (Japan's 資金決済法/コンプガチャ rules make both a
/// bigger undertaking than warranted here). Instead:
/// - some items are free for everyone (`iapProductId == null`)
/// - some are included for anyone with an active subscription
///   ([includedWithSubscription]) — bundled into the existing
///   [Entitlement]-based premium tier rather than a second paywall
/// - the rest are sold individually as ordinary non-consumable IAP,
///   keyed by [iapProductId], exactly like `SubscriptionPlan`'s own
///   purchase flow (no RNG, no loot box — what you see is what you buy)
///
/// Each app supplies its own catalog of concrete [CosmeticItem]s (the
/// actual rendering — colors, asset paths, glyph sets — is entirely
/// game-specific, e.g. a Go "board skin" and a Chess "piece skin" share
/// nothing visually), and its own purchase service converts store
/// receipts into the `purchasedProductIds` set this class checks
/// against — the same Flutter/Firebase-free boundary as [Entitlement].
class CosmeticItem {
  const CosmeticItem({
    required this.id,
    required this.category,
    required this.name,
    this.includedWithSubscription = false,
    this.iapProductId,
  });

  /// Stable identifier, unique within [category] for one app's catalog.
  /// Never reuse/repurpose once shipped — see [AvatarIcon.id]'s same
  /// warning.
  final String id;

  /// App-defined grouping, e.g. `'boardSkin'`/`'pieceSkin'` — a plain
  /// string rather than an enum since each sibling app's own cosmetic
  /// categories differ (a Go app has no "piece set" in the chess sense).
  final String category;

  /// Display name; callers localize separately (same convention as
  /// [AvatarIcon.label]).
  final String name;

  /// Whether an active subscriber gets this item for free, without an
  /// individual purchase, on top of whatever [iapProductId] it also has.
  final bool includedWithSubscription;

  /// The store product id to buy this item individually, or `null` if
  /// the item is never purchased on its own (either it's free for
  /// everyone, or subscription-only with [includedWithSubscription]
  /// true and no standalone price).
  final String? iapProductId;

  /// True if this item is free for literally everyone, regardless of
  /// subscription or purchase state.
  bool get isFreeForAll => iapProductId == null && !includedWithSubscription;

  /// Whether the given user may use this item right now.
  ///
  /// - A free-for-all item is always owned.
  /// - A subscription-included item is owned while [hasActiveSubscription]
  ///   is true (callers should pass [Entitlement.isCurrentlyActive]'s
  ///   result, not the raw stored flag).
  /// - Otherwise, owned iff [iapProductId] appears in
  ///   [purchasedProductIds] (the caller's own record of completed,
  ///   non-refunded purchases for this user).
  bool isOwnedBy({
    required bool hasActiveSubscription,
    required Set<String> purchasedProductIds,
  }) {
    if (isFreeForAll) return true;
    if (includedWithSubscription && hasActiveSubscription) return true;
    final productId = iapProductId;
    if (productId == null) return false;
    return purchasedProductIds.contains(productId);
  }
}
