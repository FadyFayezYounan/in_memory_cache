# in_memory_cache

A flexible, production-ready in-memory caching solution for Dart with configurable expiry and eviction policies.

## Features

- **Multiple Expiry Policies**
  - `EternalExpiryPolicy`: Entries never expire
  - `CreatedExpiryPolicy`: Expire after a fixed duration from creation
  - `AccessedExpiryPolicy`: Expire after a fixed duration from last access
  - `ModifiedExpiryPolicy`: Expire after a fixed duration from last modification
  - `TouchedExpiryPolicy`: Expire after a fixed duration from any operation

- **Eviction Policies**
  - `FifoEvictionPolicy`: First-In-First-Out (removes oldest entries)
  - `FiloEvictionPolicy`: First-In-Last-Out (removes newest entries)

- **Rich API**
  - Basic operations: `get`, `put`, `remove`, `clear`, `containsKey`
  - Batch operations: `getAll`, `putAll`, `removeAll`
  - Conditional operations: `putIfAbsent`
  - Atomic operations: `getAndPut`, `getAndRemove`

- **Performance**
  - O(1) average time for get/put operations
  - Lazy expiry checking for optimal performance
  - Configurable maximum entries

## Getting started

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  in_memory_cache: ^0.1.0
```

Then import it:

```dart
import 'package:in_memory_cache/in_memory_cache.dart';
```

## Usage

### Basic Usage

```dart
// Create a cache with entries that expire 5 minutes after creation
// and a maximum of 100 entries using FIFO eviction
final cache = InMemoryCache<String, int>(
  expiryPolicy: CreatedExpiryPolicy(Duration(minutes: 5)),
  maxEntries: 100,
  evictionPolicy: FifoEvictionPolicy<String>(),
);

// Add entries
cache.put('key1', 42);
cache.put('key2', 100);

// Retrieve values
print(cache.get('key1')); // 42

// Check if key exists
print(cache.containsKey('key1')); // true

// Remove an entry
cache.remove('key1');

// Clear all entries
cache.clear();
```

### Expiry Policies

#### Eternal (Never Expires)

```dart
final cache = InMemoryCache<String, String>(
  expiryPolicy: EternalExpiryPolicy(),
);
```

#### Created Expiry

Entries expire after a fixed duration from creation:

```dart
final cache = InMemoryCache<String, String>(
  expiryPolicy: CreatedExpiryPolicy(Duration(minutes: 5)),
);

cache.put('key', 'value');
// Entry expires 5 minutes after creation
```

#### Accessed Expiry

Entries expire after a fixed duration from last access (resets on read):

```dart
final cache = InMemoryCache<String, String>(
  expiryPolicy: AccessedExpiryPolicy(Duration(minutes: 5)),
);

cache.put('key', 'value');
cache.get('key'); // Resets expiry
```

#### Modified Expiry

Entries expire after a fixed duration from last modification (resets on update):

```dart
final cache = InMemoryCache<String, String>(
  expiryPolicy: ModifiedExpiryPolicy(Duration(minutes: 5)),
);

cache.put('key', 'value1');
cache.put('key', 'value2'); // Resets expiry
```

#### Touched Expiry

Entries expire after a fixed duration from any operation:

```dart
final cache = InMemoryCache<String, String>(
  expiryPolicy: TouchedExpiryPolicy(Duration(minutes: 5)),
);

cache.put('key', 'value');
cache.get('key'); // Resets expiry
cache.put('key', 'updated'); // Resets expiry again
```

### Eviction Policies

#### FIFO (First-In-First-Out)

```dart
final cache = InMemoryCache<String, int>(
  expiryPolicy: EternalExpiryPolicy(),
  maxEntries: 3,
  evictionPolicy: FifoEvictionPolicy<String>(),
);

cache.put('first', 1);
cache.put('second', 2);
cache.put('third', 3);
cache.put('fourth', 4); // Evicts 'first'
```

#### FILO (First-In-Last-Out)

```dart
final cache = InMemoryCache<String, int>(
  expiryPolicy: EternalExpiryPolicy(),
  maxEntries: 3,
  evictionPolicy: FiloEvictionPolicy<String>(),
);

cache.put('first', 1);
cache.put('second', 2);
cache.put('third', 3);
cache.put('fourth', 4); // Evicts 'third'
```

### Advanced Operations

#### Batch Operations

```dart
// Add multiple entries
cache.putAll({'a': 1, 'b': 2, 'c': 3});

// Get multiple values
final values = cache.getAll(['a', 'b', 'missing']);
// Result: {a: 1, b: 2, missing: null}

// Remove multiple entries
cache.removeAll(['a', 'c']);
```

#### Conditional Operations

```dart
// Add only if key doesn't exist
final value = cache.putIfAbsent('counter', () => 1);
// Returns 1 if key didn't exist, existing value otherwise
```

#### Atomic Operations

```dart
// Get old value and replace
final oldValue = cache.getAndPut('score', 200);

// Get value and remove
final value = cache.getAndRemove('temp');
```

## Performance Considerations

- **get()**: O(1) average case
- **put()**: O(1) average case, O(n) when eviction is triggered
- **size**: O(n) - scans to remove expired entries
- **keys**: O(n) - scans to remove expired entries

For best performance:
- Use appropriate expiry policies for your use case
- Set reasonable `maxEntries` to prevent unbounded growth
- Use `EternalExpiryPolicy` when expiry is not needed

## Additional information

For more examples, see the `/example` folder.

### Thread Safety

This cache is not thread-safe. If you need concurrent access, you should use external synchronization mechanisms.

### Contributing

Contributions are welcome! Please file issues or submit pull requests on GitHub.
