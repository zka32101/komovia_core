import 'package:komovia_core/komovia_core.dart';
import 'package:test/test.dart';

void main() {
  group('shouldShowAds', () {
    test('a user with no entitlement at all should see ads', () {
      expect(shouldShowAds(const Entitlement.none()), isTrue);
    });

    test('an active, never-expiring entitlement should not see ads', () {
      const entitlement = Entitlement(isActive: true, plan: SubscriptionPlan.lifetime);
      expect(shouldShowAds(entitlement), isFalse);
    });

    test('an entitlement marked active but whose expiresAt has passed should see ads', () {
      final entitlement = Entitlement(
        isActive: true,
        plan: SubscriptionPlan.monthly,
        expiresAt: DateTime(2020, 1, 1),
      );
      expect(shouldShowAds(entitlement, now: DateTime(2020, 2, 1)), isTrue);
    });

    test('an entitlement whose expiresAt is still in the future should not see ads', () {
      final entitlement = Entitlement(
        isActive: true,
        plan: SubscriptionPlan.monthly,
        expiresAt: DateTime(2020, 2, 1),
      );
      expect(shouldShowAds(entitlement, now: DateTime(2020, 1, 1)), isFalse);
    });
  });

  group('AdRetryPolicy.delayForAttempt', () {
    test('doubles the base delay each attempt, matching komovia_go\'s original 5s/10s/20s', () {
      expect(AdRetryPolicy.delayForAttempt(1), const Duration(seconds: 5));
      expect(AdRetryPolicy.delayForAttempt(2), const Duration(seconds: 10));
      expect(AdRetryPolicy.delayForAttempt(3), const Duration(seconds: 20));
    });

    test('returns null once attemptNumber exceeds the default max of 3', () {
      expect(AdRetryPolicy.delayForAttempt(4), isNull);
    });

    test('returns null for attemptNumber < 1', () {
      expect(AdRetryPolicy.delayForAttempt(0), isNull);
      expect(AdRetryPolicy.delayForAttempt(-1), isNull);
    });

    test('respects a custom maxRetries/baseDelay', () {
      expect(
        AdRetryPolicy.delayForAttempt(1, baseDelay: const Duration(seconds: 1)),
        const Duration(seconds: 1),
      );
      expect(
        AdRetryPolicy.delayForAttempt(5, maxRetries: 5, baseDelay: const Duration(seconds: 1)),
        const Duration(seconds: 16),
      );
      expect(
        AdRetryPolicy.delayForAttempt(2, maxRetries: 1),
        isNull,
      );
    });
  });
}
