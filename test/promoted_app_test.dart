import 'package:komovia_core/komovia_core.dart';
import 'package:test/test.dart';

void main() {
  group('PromotedApp', () {
    test('round-trips through toJson/fromJson', () {
      final app = PromotedApp(
        appId: 'komovia_shogi',
        name: 'Komovia将棋',
        tagline: 'AI対局・詰将棋',
        category: 'shogi',
        iconPath: 'assets/cross_promo/shogi.png',
        iosStoreUrl: 'https://apps.apple.com/app/id1111111111',
        androidStoreUrl:
            'https://play.google.com/store/apps/details?id=com.yourwish.shogi',
      );

      final restored = PromotedApp.fromJson(app.toJson());

      expect(restored.appId, app.appId);
      expect(restored.name, app.name);
      expect(restored.tagline, app.tagline);
      expect(restored.category, app.category);
      expect(restored.iconPath, app.iconPath);
      expect(restored.iosStoreUrl, app.iosStoreUrl);
      expect(restored.androidStoreUrl, app.androidStoreUrl);
    });

    test('store URLs are optional and round-trip as null', () {
      const app = PromotedApp(
        appId: 'komovia_go',
        name: 'Komovia囲碁',
        tagline: 'AI対局・詰碁',
        category: 'go',
        iconPath: 'assets/cross_promo/go.png',
      );

      final restored = PromotedApp.fromJson(app.toJson());

      expect(restored.iosStoreUrl, isNull);
      expect(restored.androidStoreUrl, isNull);
    });

    test('storeUrlFor picks the URL matching the platform', () {
      const app = PromotedApp(
        appId: 'komovia_chess',
        name: 'Komoviaチェス',
        tagline: 'AI対局・タクティクス',
        category: 'chess',
        iconPath: 'assets/cross_promo/chess.png',
        iosStoreUrl: 'https://apps.apple.com/app/id2222222222',
        androidStoreUrl:
            'https://play.google.com/store/apps/details?id=com.yourwish.chess',
      );

      expect(app.storeUrlFor(isIOS: true), app.iosStoreUrl);
      expect(app.storeUrlFor(isIOS: false), app.androidStoreUrl);
    });

    test('storeUrlFor returns null when the app has no URL for that store', () {
      const app = PromotedApp(
        appId: 'komovia_go',
        name: 'Komovia囲碁',
        tagline: 'AI対局・詰碁',
        category: 'go',
        iconPath: 'assets/cross_promo/go.png',
        androidStoreUrl:
            'https://play.google.com/store/apps/details?id=com.yourwish.go',
      );

      expect(app.storeUrlFor(isIOS: true), isNull);
      expect(app.storeUrlFor(isIOS: false), isNotNull);
    });

    test('copyWith can explicitly clear a nullable store URL', () {
      const app = PromotedApp(
        appId: 'komovia_shogi',
        name: 'Komovia将棋',
        tagline: 'AI対局・詰将棋',
        category: 'shogi',
        iconPath: 'assets/cross_promo/shogi.png',
        iosStoreUrl: 'https://apps.apple.com/app/id1111111111',
      );

      final cleared = app.copyWith(iosStoreUrl: null);

      expect(cleared.iosStoreUrl, isNull);
      // Unpassed fields are preserved.
      expect(cleared.name, app.name);
    });

    test('copyWith leaves fields untouched when not passed', () {
      const app = PromotedApp(
        appId: 'komovia_chess',
        name: 'Komoviaチェス',
        tagline: 'AI対局・タクティクス',
        category: 'chess',
        iconPath: 'assets/cross_promo/chess.png',
        iosStoreUrl: 'https://apps.apple.com/app/id2222222222',
      );

      final copy = app.copyWith(name: '新しい名前');

      expect(copy.name, '新しい名前');
      expect(copy.iosStoreUrl, app.iosStoreUrl);
      expect(copy.tagline, app.tagline);
    });
  });

  group('otherKomoviaApps', () {
    final roster = [
      const PromotedApp(
        appId: 'komovia_shogi',
        name: 'Komovia将棋',
        tagline: 'AI対局・詰将棋',
        category: 'shogi',
        iconPath: 'assets/cross_promo/shogi.png',
      ),
      const PromotedApp(
        appId: 'komovia_go',
        name: 'Komovia囲碁',
        tagline: 'AI対局・詰碁',
        category: 'go',
        iconPath: 'assets/cross_promo/go.png',
      ),
      const PromotedApp(
        appId: 'komovia_chess',
        name: 'Komoviaチェス',
        tagline: 'AI対局・タクティクス',
        category: 'chess',
        iconPath: 'assets/cross_promo/chess.png',
      ),
    ];

    test('excludes the current app and keeps the rest', () {
      final others = otherKomoviaApps(roster, 'komovia_chess');

      expect(others.map((a) => a.appId), ['komovia_shogi', 'komovia_go']);
    });

    test('returns the full roster when currentAppId matches none of it', () {
      final others = otherKomoviaApps(roster, 'some_other_app');

      expect(others.length, roster.length);
    });
  });
}
