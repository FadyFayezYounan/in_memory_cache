import 'package:in_memory_cache/in_memory_cache.dart';

void main() {
  final cache = Cache<String, int>(
    expiryPolicy: EternalExpiryPolicy(),
    maxEntries: 100,
  );

  print('=== Conditional Operations ===');
  conditionalOperations(cache);

  cache.clear();
  print('\n=== Atomic Operations ===');
  atomicOperations(cache);

  cache.clear();
  print('\n=== Batch Operations ===');
  batchOperations(cache);
}

void conditionalOperations(Cache<String, int> cache) {
  // putIfAbsent - only adds if key doesn't exist
  final value1 = cache.putIfAbsent('counter', () {
    print('Creating counter');
    return 1;
  });
  print('Counter: $value1'); // 1

  final value2 = cache.putIfAbsent('counter', () {
    print('This will not be called');
    return 999;
  });
  print('Counter (unchanged): $value2'); // 1
}

void atomicOperations(Cache<String, int> cache) {
  // getAndPut - get old value and replace with new
  cache.put('score', 100);
  final oldScore = cache.getAndPut('score', 200);
  print('Old score: $oldScore'); // 100
  print('New score: ${cache.get('score')}'); // 200

  // getAndRemove - get value and remove entry
  final removedScore = cache.getAndRemove('score');
  print('Removed score: $removedScore'); // 200
  print('Score exists: ${cache.containsKey('score')}'); // false

  // These return null for non-existent keys
  final nonExistent = cache.getAndPut('missing', 42);
  print('Non-existent: $nonExistent'); // null
}

void batchOperations(Cache<String, int> cache) {
  // putAll - add multiple entries
  cache.putAll({
    'a': 1,
    'b': 2,
    'c': 3,
    'd': 4,
  });
  print('Added 4 entries, size: ${cache.size}'); // 4

  // getAll - retrieve multiple values
  final values = cache.getAll(['a', 'b', 'missing', 'd']);
  print('Batch get: $values'); // {a: 1, b: 2, missing: null, d: 4}

  // removeAll - remove multiple entries
  cache.removeAll(['a', 'c']);
  print('After removing a and c, size: ${cache.size}'); // 2
  print('Remaining keys: ${cache.keys}'); // [b, d]
}
