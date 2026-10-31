import 'package:komovia_core/komovia_core.dart';
import 'package:test/test.dart';

void main() {
  group('Entitlement', () {
    test('Entitlement.none has no plan and is inactive', () {
      const entitlement = Entitlement.none();
      expect(entitlement.isActive, isFalse);
      expect(entitlement.plan, isNull);
      expect(entitlement.isCurrentlyActive(), isFalse);
      expect(entitlement.isLifetime, isFalse);
    });

    test('round-trips through toJson/fromJson', () {
      final entitlement = Entitlement(
        isActive: true,
        plan: SubscriptionPlan.annual,
        startedAt: DateTime.utc(2026, 1, 1),
        expiresAt: DateTime.utc(2027, 1, 1),
      );

      final restored = Entitlement.fromJson(entitlement.toJson());

      expect(restored.isActive, entitlement.isActive);
      expect(restored.plan, entitlement.plan);
      expect(restored.startedAt, entitlement.startedAt);
      expect(restored.expiresAt, entitlement.expiresAt);
    });

    test('a lifetime entitlement has no expiresAt and round-trips as null',
        () {
      final entitlement = Entitlement(
        isActive: true,
        plan: SubscriptionPlan.lifetime,
        startedAt: DateTime.utc(2026, 1, 1),
      );

      final restored = Entitlement.fromJson(entitlement.toJson());

      expect(restored.expiresAt, isNull);
      expect(restored.isLifetime, isTrue);
      expect(restored.isCurrentlyActive(), isTrue);
    });

    test('isCurrentlyActive re-derives from expiresAt rather than trusting '
        'a stale isActive flag', () {
      final expired = Entitlement(
        isActive: true,
        plan: SubscriptionPlan.monthly,
        startedAt: DateTime.utc(2020, 1, 1),
        expiresAt: DateTime.utc(2020, 2, 1),
      );

      expect(expired.isCurrentlyActive(now: DateTime.utc(2026, 1, 1)),
          isFalse);
      expect(expired.isCurrentlyActive(now: DateTime.utc(2020, 1, 15)),
          isTrue);
    });

    test('isCurrentlyActive is false whenever isActive itself is false', () {
      final notActive = Entitlement(
        isActive: false,
        plan: SubscriptionPlan.monthly,
        expiresAt: DateTime.utc(2099, 1, 1),
      );
      expect(notActive.isCurrentlyActive(), isFalse);
    });

    test('copyWith overrides only the given fields', () {
      final entitlement = Entitlement(
        isActive: true,
        plan: SubscriptionPlan.monthly,
        startedAt: DateTime.utc(2026, 1, 1),
        expiresAt: DateTime.utc(2026, 2, 1),
      );

      final upgraded = entitlement.copyWith(plan: SubscriptionPlan.annual);

      expect(upgraded.plan, SubscriptionPlan.annual);
      expect(upgraded.isActive, entitlement.isActive);
      expect(upgraded.startedAt, entitlement.startedAt);
    });

    test('an unrecognized stored plan name falls back to monthly rather '
        'than throwing', () {
      final restored = Entitlement.fromJson({
        'isActive': true,
        'plan': 'some_future_plan',
      });
      expect(restored.plan, SubscriptionPlan.monthly);
    });
  });

  group('SubscriptionPlan.entitlementLength', () {
    test('monthly is 30 days', () {
      expect(SubscriptionPlan.monthly.entitlementLength,
          const Duration(days: 30));
    });

    test('annual is 365 days', () {
      expect(SubscriptionPlan.annual.entitlementLength,
          const Duration(days: 365));
    });

    test('lifetime never expires', () {
      expect(SubscriptionPlan.lifetime.entitlementLength, isNull);
    });
  });
}
