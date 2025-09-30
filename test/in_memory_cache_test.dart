import 'package:in_memory_cache/in_memory_cache.dart';
import 'package:test/test.dart';

void main() {
  group('Integration Tests', () {
    test('Complete workflow with all features', () {
      final cache = Cache<String, int>(
        expiryPolicy: EternalExpiryPolicy(),
        maxEntries: 10,
        evictionPolicy: FifoEvictionPolicy<String>(),
      );

      // Add entries
      cache.putAll({'a': 1, 'b': 2, 'c': 3});

      // Verify
      expect(cache.size, equals(3));
      expect(cache.get('a'), equals(1));

      // Batch operations
      final values = cache.getAll(['a', 'b', 'c']);
      expect(values.values.every((v) => v != null), isTrue);

      // Clear
      cache.clear();
      expect(cache.size, equals(0));
    });
  });
}
