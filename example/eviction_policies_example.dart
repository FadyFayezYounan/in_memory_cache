import 'package:in_memory_cache/in_memory_cache.dart';

void main() {
  print('=== FIFO Eviction Policy ===');
  fifoExample();

  print('\n=== FILO Eviction Policy ===');
  filoExample();

  print('\n=== No Eviction Policy ===');
  noEvictionExample();
}

void fifoExample() {
  // First-In-First-Out: oldest entries are evicted first
  final cache = Cache<String, int>(
    expiryPolicy: EternalExpiryPolicy(),
    maxEntries: 3,
    evictionPolicy: FifoEvictionPolicy<String>(),
  );

  cache.put('first', 1);
  cache.put('second', 2);
  cache.put('third', 3);
  print('Added 3 entries: ${cache.keys}'); // [first, second, third]

  cache.put('fourth', 4); // Evicts 'first'
  print('After adding fourth: ${cache.keys}'); // [second, third, fourth]
  print('First is gone: ${cache.containsKey('first')}'); // false

  cache.put('fifth', 5); // Evicts 'second'
  print('After adding fifth: ${cache.keys}'); // [third, fourth, fifth]
  print('Second is gone: ${cache.containsKey('second')}'); // false
}

void filoExample() {
  // First-In-Last-Out: newest entries are evicted first
  final cache = Cache<String, int>(
    expiryPolicy: EternalExpiryPolicy(),
    maxEntries: 3,
    evictionPolicy: FiloEvictionPolicy<String>(),
  );

  cache.put('first', 1);
  cache.put('second', 2);
  cache.put('third', 3);
  print('Added 3 entries: ${cache.keys}'); // [first, second, third]

  cache.put('fourth', 4); // Evicts 'third'
  print('After adding fourth: ${cache.keys}'); // [first, second, fourth]
  print('Third is gone: ${cache.containsKey('third')}'); // false

  cache.put('fifth', 5); // Evicts 'fourth'
  print('After adding fifth: ${cache.keys}'); // [first, second, fifth]
  print('Fourth is gone: ${cache.containsKey('fourth')}'); // false
}

void noEvictionExample() {
  // Without eviction policy, cache can grow without limit
  final cache = Cache<String, int>(
    expiryPolicy: EternalExpiryPolicy(),
    // No maxEntries or evictionPolicy
  );

  for (int i = 0; i < 1000; i++) {
    cache.put('key$i', i);
  }

  print('Cache size: ${cache.size}'); // 1000
  print('No entries evicted');
}
