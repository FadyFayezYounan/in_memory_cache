import 'package:in_memory_cache/in_memory_cache.dart';
import 'package:test/test.dart';

void main() {
  group('InMemoryCache - Basic Operations', () {
    late Cache<String, int> cache;

    setUp(() {
      cache = Cache<String, int>(
        expiryPolicy: EternalExpiryPolicy(),
      );
    });

    test('put and get', () {
      cache.put('key1', 42);
      expect(cache.get('key1'), equals(42));
    });

    test('get returns null for non-existent key', () {
      expect(cache.get('missing'), isNull);
    });

    test('containsKey', () {
      cache.put('key1', 42);
      expect(cache.containsKey('key1'), isTrue);
      expect(cache.containsKey('missing'), isFalse);
    });

    test('remove', () {
      cache.put('key1', 42);
      final removed = cache.remove('key1');

      expect(removed, equals(42));
      expect(cache.containsKey('key1'), isFalse);
    });

    test('remove returns null for non-existent key', () {
      expect(cache.remove('missing'), isNull);
    });

    test('size', () {
      expect(cache.size, equals(0));

      cache.put('key1', 1);
      cache.put('key2', 2);
      expect(cache.size, equals(2));

      cache.remove('key1');
      expect(cache.size, equals(1));
    });

    test('keys', () {
      cache.put('key1', 1);
      cache.put('key2', 2);
      cache.put('key3', 3);

      final keys = cache.keys.toList();
      expect(keys.length, equals(3));
      expect(keys, containsAll(['key1', 'key2', 'key3']));
    });

    test('clear', () {
      cache.put('key1', 1);
      cache.put('key2', 2);

      cache.clear();

      expect(cache.size, equals(0));
      expect(cache.containsKey('key1'), isFalse);
    });

    test('update existing entry', () {
      cache.put('key1', 1);
      cache.put('key1', 2);

      expect(cache.get('key1'), equals(2));
      expect(cache.size, equals(1));
    });
  });

  group('InMemoryCache - Batch Operations', () {
    late Cache<String, int> cache;

    setUp(() {
      cache = Cache<String, int>(
        expiryPolicy: EternalExpiryPolicy(),
      );
    });

    test('getAll', () {
      cache.put('key1', 1);
      cache.put('key2', 2);

      final result = cache.getAll(['key1', 'key2', 'missing']);

      expect(result, equals({'key1': 1, 'key2': 2, 'missing': null}));
    });

    test('putAll', () {
      cache.putAll({'key1': 1, 'key2': 2, 'key3': 3});

      expect(cache.size, equals(3));
      expect(cache.get('key1'), equals(1));
      expect(cache.get('key2'), equals(2));
      expect(cache.get('key3'), equals(3));
    });

    test('removeAll', () {
      cache.putAll({'key1': 1, 'key2': 2, 'key3': 3});
      cache.removeAll(['key1', 'key3']);

      expect(cache.size, equals(1));
      expect(cache.containsKey('key2'), isTrue);
    });
  });

  group('InMemoryCache - Conditional Operations', () {
    late Cache<String, int> cache;

    setUp(() {
      cache = Cache<String, int>(
        expiryPolicy: EternalExpiryPolicy(),
      );
    });

    test('putIfAbsent adds when key does not exist', () {
      final result = cache.putIfAbsent('key1', () => 42);

      expect(result, equals(42));
      expect(cache.get('key1'), equals(42));
    });

    test('putIfAbsent does not add when key exists', () {
      cache.put('key1', 42);

      var called = false;
      final result = cache.putIfAbsent('key1', () {
        called = true;
        return 100;
      });

      expect(result, equals(42));
      expect(called, isFalse);
      expect(cache.get('key1'), equals(42));
    });
  });

  group('InMemoryCache - Atomic Operations', () {
    late Cache<String, int> cache;

    setUp(() {
      cache = Cache<String, int>(
        expiryPolicy: EternalExpiryPolicy(),
      );
    });

    test('getAndPut returns old value', () {
      cache.put('key1', 42);

      final oldValue = cache.getAndPut('key1', 100);

      expect(oldValue, equals(42));
      expect(cache.get('key1'), equals(100));
    });

    test('getAndPut returns null for non-existent key', () {
      final oldValue = cache.getAndPut('key1', 100);

      expect(oldValue, isNull);
      expect(cache.get('key1'), equals(100));
    });

    test('getAndRemove returns value and removes entry', () {
      cache.put('key1', 42);

      final value = cache.getAndRemove('key1');

      expect(value, equals(42));
      expect(cache.containsKey('key1'), isFalse);
    });

    test('getAndRemove returns null for non-existent key', () {
      final value = cache.getAndRemove('missing');

      expect(value, isNull);
    });
  });

  group('InMemoryCache - Expiry Integration', () {
    test('CreatedExpiryPolicy expires entries', () async {
      final cache = Cache<String, int>(
        expiryPolicy: CreatedExpiryPolicy(Duration(milliseconds: 100)),
      );

      cache.put('key1', 42);
      expect(cache.get('key1'), equals(42));

      await Future.delayed(Duration(milliseconds: 150));

      expect(cache.get('key1'), isNull);
      expect(cache.containsKey('key1'), isFalse);
    });

    test('AccessedExpiryPolicy resets expiry on access', () async {
      final cache = Cache<String, int>(
        expiryPolicy: AccessedExpiryPolicy(Duration(milliseconds: 100)),
      );

      cache.put('key1', 42);

      await Future.delayed(Duration(milliseconds: 60));
      cache.get('key1'); // Reset expiry

      await Future.delayed(Duration(milliseconds: 60));
      expect(cache.get('key1'), equals(42)); // Still valid

      await Future.delayed(Duration(milliseconds: 150));
      expect(cache.get('key1'), isNull); // Now expired
    });

    test('ModifiedExpiryPolicy resets expiry on update', () async {
      final cache = Cache<String, int>(
        expiryPolicy: ModifiedExpiryPolicy(Duration(milliseconds: 100)),
      );

      cache.put('key1', 42);

      await Future.delayed(Duration(milliseconds: 60));
      cache.put('key1', 100); // Reset expiry

      await Future.delayed(Duration(milliseconds: 60));
      expect(cache.get('key1'), equals(100)); // Still valid

      await Future.delayed(Duration(milliseconds: 150));
      expect(cache.get('key1'), isNull); // Now expired
    });
  });

  group('InMemoryCache - Eviction', () {
    test('FIFO eviction removes oldest entries', () {
      final cache = Cache<String, int>(
        expiryPolicy: EternalExpiryPolicy(),
        maxEntries: 3,
        evictionPolicy: FifoEvictionPolicy<String>(),
      );

      cache.put('first', 1);
      cache.put('second', 2);
      cache.put('third', 3);
      cache.put('fourth', 4); // Evicts 'first'

      expect(cache.containsKey('first'), isFalse);
      expect(cache.containsKey('second'), isTrue);
      expect(cache.containsKey('third'), isTrue);
      expect(cache.containsKey('fourth'), isTrue);
    });

    test('FILO eviction removes newest entries', () {
      final cache = Cache<String, int>(
        expiryPolicy: EternalExpiryPolicy(),
        maxEntries: 3,
        evictionPolicy: FiloEvictionPolicy<String>(),
      );

      cache.put('first', 1);
      cache.put('second', 2);
      cache.put('third', 3);
      cache.put('fourth', 4); // Evicts 'third'

      expect(cache.containsKey('first'), isTrue);
      expect(cache.containsKey('second'), isTrue);
      expect(cache.containsKey('third'), isFalse);
      expect(cache.containsKey('fourth'), isTrue);
    });

    test('throws ArgumentError for invalid maxEntries', () {
      expect(
        () => Cache<String, int>(
          expiryPolicy: EternalExpiryPolicy(),
          maxEntries: 0,
        ),
        throwsArgumentError,
      );

      expect(
        () => Cache<String, int>(
          expiryPolicy: EternalExpiryPolicy(),
          maxEntries: -1,
        ),
        throwsArgumentError,
      );
    });
  });
}
