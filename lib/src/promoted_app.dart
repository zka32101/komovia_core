/// One other app to promote for cross-promotion within the Komovia
/// family (shogi/go/chess, and future board games), game-agnostic by
/// design.
///
/// This is deliberately a plain Dart data class — no Firebase/Remote
/// Config dependency — to keep komovia_core Flutter-free, the same way
/// [AppNotification]/[Friendship]/[DirectMessage] are. Each game app's
/// own cross-promo screen/widget is responsible for supplying the list
/// of [PromotedApp]s (its sibling apps minus itself) and for the actual
/// "open the store" action, however it fetches that list (a hardcoded
/// roster of the known Komovia siblings is the obvious choice for a
/// closed family this small — there's no need for a Remote-Config-driven
/// list the way an open-ended portfolio would want one).
///
/// Distinct from `zka32101/cross_promo_kit`, which is a separate,
/// unrelated package for cross-promotion across the "Petit Works"
/// portfolio (小学コレ/うかラボ-style apps) — that package's
/// `firebase_remote_config`-backed design and promoted-app list are
/// specific to that other app family, not Komovia's, and pulling it in
/// here would also break komovia_core's "no Flutter/Firebase" invariant.
class PromotedApp {
  /// Short, stable identifier for the app (e.g. `'komovia_shogi'`),
  /// used to exclude the current app from its own promoted-apps list.
  final String appId;

  /// Display name shown in the cross-promo card (e.g. `'Komovia将棋'`).
  final String name;

  /// One-line pitch shown under the name.
  final String tagline;

  /// `'shogi'`, `'go'`, `'chess'`, or a future sibling's category —
  /// not an enum, since the Komovia family is expected to grow.
  final String category;

  /// Asset path (bundled with the promoting app) or a URL for the
  /// promoted app's icon. Either is valid; the promoting app's widget
  /// decides how to render whichever it was given.
  final String iconPath;

  final String? iosStoreUrl;
  final String? androidStoreUrl;

  const PromotedApp({
    required this.appId,
    required this.name,
    required this.tagline,
    required this.category,
    required this.iconPath,
    this.iosStoreUrl,
    this.androidStoreUrl,
  });

  /// The store URL to open for the current platform, or null if this
  /// app isn't listed on that store (e.g. not yet released there).
  /// [isIOS] is supplied by the caller (e.g. `Platform.isIOS` or
  /// `defaultTargetPlatform`) since komovia_core doesn't import
  /// `dart:io`/Flutter.
  String? storeUrlFor({required bool isIOS}) =>
      isIOS ? iosStoreUrl : androidStoreUrl;

  PromotedApp copyWith({
    String? appId,
    String? name,
    String? tagline,
    String? category,
    String? iconPath,
    Object? iosStoreUrl = _unset,
    Object? androidStoreUrl = _unset,
  }) {
    return PromotedApp(
      appId: appId ?? this.appId,
      name: name ?? this.name,
      tagline: tagline ?? this.tagline,
      category: category ?? this.category,
      iconPath: iconPath ?? this.iconPath,
      iosStoreUrl:
          iosStoreUrl == _unset ? this.iosStoreUrl : iosStoreUrl as String?,
      androidStoreUrl: androidStoreUrl == _unset
          ? this.androidStoreUrl
          : androidStoreUrl as String?,
    );
  }

  Map<String, Object?> toJson() => {
        'appId': appId,
        'name': name,
        'tagline': tagline,
        'category': category,
        'iconPath': iconPath,
        'iosStoreUrl': iosStoreUrl,
        'androidStoreUrl': androidStoreUrl,
      };

  factory PromotedApp.fromJson(Map<String, Object?> json) {
    return PromotedApp(
      appId: json['appId'] as String,
      name: json['name'] as String,
      tagline: json['tagline'] as String,
      category: json['category'] as String,
      iconPath: json['iconPath'] as String,
      iosStoreUrl: json['iosStoreUrl'] as String?,
      androidStoreUrl: json['androidStoreUrl'] as String?,
    );
  }
}

/// Picks every [PromotedApp] in [roster] other than [currentAppId] —
/// the one piece of cross-promo "logic" that's actually game-agnostic
/// and worth sharing; everything else (fetching the roster, rendering
/// the card, opening the store) is each app's own concern.
List<PromotedApp> otherKomoviaApps(
  List<PromotedApp> roster,
  String currentAppId,
) =>
    roster.where((app) => app.appId != currentAppId).toList();

/// Sentinel used by [PromotedApp.copyWith] to distinguish "not passed"
/// from an explicit `null`, so a nullable field can actually be cleared.
const Object _unset = Object();
