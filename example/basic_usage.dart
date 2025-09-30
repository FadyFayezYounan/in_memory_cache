import 'package:in_memory_cache/in_memory_cache.dart';

void main() {
  // Create a cache with entries that expire 5 minutes after creation
  // and a maximum of 100 entries using FIFO eviction
  final cache = Cache<String, int>(
    expiryPolicy: CreatedExpiryPolicy(Duration(minutes: 5)),
    maxEntries: 100,
    evictionPolicy: FifoEvictionPolicy<String>(),
  );

  // Add entries
  cache.put('key1', 42);
  cache.put('key2', 100);

  // Retrieve values
  print('key1: ${cache.get('key1')}'); // 42
  print('key2: ${cache.get('key2')}'); // 100

  // Check if key exists
  print('Contains key1: ${cache.containsKey('key1')}'); // true

  // Get cache size
  print('Cache size: ${cache.size}'); // 2

  // Remove an entry
  final removed = cache.remove('key1');
  print('Removed value: $removed'); // 42

  // Batch operations
  cache.putAll({'key3': 300, 'key4': 400});
  final values = cache.getAll(['key2', 'key3', 'key4']);
  print('Batch get: $values'); // {key2: 100, key3: 300, key4: 400}

  // Clear all entries
  cache.clear();
  print('Cache size after clear: ${cache.size}'); // 0
}
