import 'package:in_memory_cache/in_memory_cache.dart';
import 'package:test/test.dart';

void main() {
  group('ExpiryPolicy', () {
    test('EternalExpiryPolicy never expires', () {
      final policy = EternalExpiryPolicy();
      expect(policy.getExpiryForCreation(), isNull);
      expect(policy.getExpiryForAccess(), isNull);
      expect(policy.getExpiryForUpdate(), isNull);
    });

    test('CreatedExpiryPolicy expires on creation only', () {
      final duration = Duration(minutes: 5);
      final policy = CreatedExpiryPolicy(duration);

      expect(policy.getExpiryForCreation(), equals(duration));
      expect(policy.getExpiryForAccess(), isNull);
      expect(policy.getExpiryForUpdate(), isNull);
    });

    test('AccessedExpiryPolicy expires on access', () {
      final duration = Duration(minutes: 10);
      final policy = AccessedExpiryPolicy(duration);

      expect(policy.getExpiryForCreation(), equals(duration));
      expect(policy.getExpiryForAccess(), equals(duration));
      expect(policy.getExpiryForUpdate(), isNull);
    });

    test('ModifiedExpiryPolicy expires on modification', () {
      final duration = Duration(hours: 1);
      final policy = ModifiedExpiryPolicy(duration);

      expect(policy.getExpiryForCreation(), equals(duration));
      expect(policy.getExpiryForAccess(), isNull);
      expect(policy.getExpiryForUpdate(), equals(duration));
    });

    test('TouchedExpiryPolicy expires on any operation', () {
      final duration = Duration(seconds: 30);
      final policy = TouchedExpiryPolicy(duration);

      expect(policy.getExpiryForCreation(), equals(duration));
      expect(policy.getExpiryForAccess(), equals(duration));
      expect(policy.getExpiryForUpdate(), equals(duration));
    });
  });
}
