/// A user's current paid-subscription entitlement, game-agnostic.
///
/// Like [AppNotification]/`Friendship`, this is deliberately a plain Dart
/// data class — no `cloud_firestore`/`in_app_purchase` dependency — to
/// keep komovia_core Flutter/Firebase-free. Each game app's own purchase
/// service converts to/from this shape at its own storage boundary.
///
/// Extracted after comparing `zka32101/chess`'s `PaywallService` (fields
/// `subscriptionTier`/`subscriptionExpiry`/`isLifetime`) and
/// `zka32101/goen`'s `PurchaseService`/`User` (fields
/// `subscriptionActive`/`subscriptionStartDate`/`subscriptionEndDate`) —
/// the two apps persist entitlement under entirely different Firestore
/// field names today, so this model intentionally does NOT force either
/// app to rename its existing Firestore fields; it's a shared shape each
/// app's own service maps its existing fields onto, the same way
/// `Game.encode`/`decode` keeps `Position` free of any one notation.
/// `komovia_shogi` has no monetization implementation yet as of this
/// writing, so has nothing to adapt.
class Entitlement {
  /// Whether the user currently has paid access. `false` whenever
  /// [expiresAt] is in the past, even if a caller forgets to re-derive it
  /// — see [isCurrentlyActive].
  final bool isActive;

  /// Which plan granted this entitlement, if any is on record. `null`
  /// for a user who has never purchased anything (see [Entitlement.none]).
  final SubscriptionPlan? plan;

  final DateTime? startedAt;

  /// `null` means "never expires" — a [SubscriptionPlan.lifetime]
  /// purchase, or (for an app that hasn't adopted per-plan lifetimes) a
  /// grandfathered active entitlement with no expiry on record.
  final DateTime? expiresAt;

  const Entitlement({
    required this.isActive,
    this.plan,
    this.startedAt,
    this.expiresAt,
  });

  /// A user with no purchase history at all.
  const Entitlement.none()
      : isActive = false,
        plan = null,
        startedAt = null,
        expiresAt = null;

  /// [isActive] re-derived from [expiresAt] against [now] (defaults to
  /// the real current time) rather than trusting the stored flag, which
  /// a caller may not have refreshed since [expiresAt] passed.
  bool isCurrentlyActive({DateTime? now}) {
    if (!isActive) return false;
    if (expiresAt == null) return true;
    return expiresAt!.isAfter(now ?? DateTime.now());
  }

  bool get isLifetime => isActive && plan == SubscriptionPlan.lifetime;

  Entitlement copyWith({
    bool? isActive,
    SubscriptionPlan? plan,
    DateTime? startedAt,
    DateTime? expiresAt,
  }) {
    return Entitlement(
      isActive: isActive ?? this.isActive,
      plan: plan ?? this.plan,
      startedAt: startedAt ?? this.startedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  /// Round-trips through plain JSON-compatible values (`DateTime` as
  /// ISO8601 strings) — storage-agnostic, same convention as
  /// `AppNotification.toJson`/`fromJson`.
  Map<String, Object?> toJson() => {
        'isActive': isActive,
        'plan': plan?.name,
        'startedAt': startedAt?.toIso8601String(),
        'expiresAt': expiresAt?.toIso8601String(),
      };

  factory Entitlement.fromJson(Map<String, Object?> json) {
    final planName = json['plan'] as String?;
    return Entitlement(
      isActive: json['isActive'] as bool? ?? false,
      plan: planName == null
          ? null
          : SubscriptionPlan.values.firstWhere(
              (p) => p.name == planName,
              orElse: () => SubscriptionPlan.monthly,
            ),
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }
}

/// The length/renewal shape a subscription purchase grants.
///
/// Not every app offers every plan today (e.g. `goen`'s `PaywallScreen`
/// has no lifetime card; `chess`'s `PaywallService` has no UI at all) —
/// this enumerates the union of plans either app has modeled, so a
/// future shared purchase flow has one vocabulary to target.
enum SubscriptionPlan { monthly, annual, lifetime }

extension SubscriptionPlanEntitlementLength on SubscriptionPlan {
  /// How long a purchase of this plan grants access for, from the
  /// moment it's recorded. `null` for [SubscriptionPlan.lifetime] —
  /// never expires.
  Duration? get entitlementLength {
    switch (this) {
      case SubscriptionPlan.monthly:
        return const Duration(days: 30);
      case SubscriptionPlan.annual:
        return const Duration(days: 365);
      case SubscriptionPlan.lifetime:
        return null;
    }
  }
}
