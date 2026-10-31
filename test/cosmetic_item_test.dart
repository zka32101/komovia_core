import 'package:komovia_core/komovia_core.dart';
import 'package:test/test.dart';

void main() {
  group('CosmeticItem.isFreeForAll', () {
    test('true when no iapProductId and not subscription-included', () {
      const item =
          CosmeticItem(id: 'wood', category: 'boardSkin', name: 'Wood');
      expect(item.isFreeForAll, isTrue);
    });

    test('false when it has an iapProductId', () {
      const item = CosmeticItem(
        id: 'kaya',
        category: 'boardSkin',
        name: 'Kaya',
        iapProductId: 'cosmetic.board.kaya',
      );
      expect(item.isFreeForAll, isFalse);
    });

    test('false when subscription-included even without an iapProductId', () {
      const item = CosmeticItem(
        id: 'premium_wood',
        category: 'boardSkin',
        name: 'Premium Wood',
        includedWithSubscription: true,
      );
      expect(item.isFreeForAll, isFalse);
    });
  });

  group('CosmeticItem.isOwnedBy', () {
    test('free-for-all item is always owned', () {
      const item =
          CosmeticItem(id: 'wood', category: 'boardSkin', name: 'Wood');
      expect(
        item.isOwnedBy(hasActiveSubscription: false, purchasedProductIds: {}),
        isTrue,
      );
    });

    test('subscription-included item owned only while subscribed', () {
      const item = CosmeticItem(
        id: 'premium_wood',
        category: 'boardSkin',
        name: 'Premium Wood',
        includedWithSubscription: true,
      );
      expect(
        item.isOwnedBy(hasActiveSubscription: true, purchasedProductIds: {}),
        isTrue,
      );
      expect(
        item.isOwnedBy(hasActiveSubscription: false, purchasedProductIds: {}),
        isFalse,
      );
    });

    test('purchasable item owned iff its product id was purchased', () {
      const item = CosmeticItem(
        id: 'kaya',
        category: 'boardSkin',
        name: 'Kaya',
        iapProductId: 'cosmetic.board.kaya',
      );
      expect(
        item.isOwnedBy(
          hasActiveSubscription: false,
          purchasedProductIds: {'cosmetic.board.kaya'},
        ),
        isTrue,
      );
      expect(
        item.isOwnedBy(hasActiveSubscription: false, purchasedProductIds: {}),
        isFalse,
      );
    });

    test('purchasable item also includedWithSubscription is owned either way',
        () {
      const item = CosmeticItem(
        id: 'kaya',
        category: 'boardSkin',
        name: 'Kaya',
        includedWithSubscription: true,
        iapProductId: 'cosmetic.board.kaya',
      );
      expect(
        item.isOwnedBy(hasActiveSubscription: true, purchasedProductIds: {}),
        isTrue,
      );
      expect(
        item.isOwnedBy(
          hasActiveSubscription: false,
          purchasedProductIds: {'cosmetic.board.kaya'},
        ),
        isTrue,
      );
      expect(
        item.isOwnedBy(hasActiveSubscription: false, purchasedProductIds: {}),
        isFalse,
      );
    });
  });
}
