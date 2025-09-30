import 'cache_entry.dart';
import 'eviction_policy/fifo_eviction_policy.dart';
import 'expiry_policy/created_expiry_policy.dart';
import 'expiry_policy/eternal_expiry_policy.dart';
import 'expiry_policy/expiry_policy.dart';
import 'eviction_policy/eviction_policy.dart';

/// A flexible in-memory cache with configurable expiry and eviction policies.
///
/// Example:
/// ```dart
/// final cache = InMemoryCache<String, int>(
///   expiryPolicy: CreatedExpiryPolicy(Duration(minutes: 5)),
///   maxEntries: 100,
///   evictionPolicy: FifoEvictionPolicy<String>(),
/// );
///
/// cache.put('key1', 42);
/// final value = cache.get('key1'); // 42
/// ```

typedef InMemoryCacheStringKey<V> = Cache<String, V>;

class InMemoryCache<V> extends Cache<String, V> {
  InMemoryCache({
    required super.expiryPolicy,
    super.evictionPolicy,
    super.maxEntries,
  });

  InMemoryCache.withDefaults() : super.withDefaults();
}

class Cache<K, V> {
  final Map<K, CacheEntry<V>> _cache = {};
  final ExpiryPolicy _expiryPolicy;
  final EvictionPolicy<K>? _evictionPolicy;
  final int? _maxEntries;

  /// Creates a new cache with the specified policies.
  ///
  /// [expiryPolicy] determines when entries expire.
  /// [evictionPolicy] determines which entries to remove when the cache is full.
  /// [maxEntries] sets the maximum number of entries (null for unlimited).
  Cache({
    ExpiryPolicy? expiryPolicy,
    EvictionPolicy<K>? evictionPolicy,
    int? maxEntries,
  })  : _expiryPolicy = expiryPolicy ?? EternalExpiryPolicy(),
        _evictionPolicy = evictionPolicy,
        _maxEntries = maxEntries {
    if (maxEntries != null && maxEntries <= 0) {
      throw ArgumentError('maxEntries must be positive');
    }
  }

  Cache.withDefaults({
    ExpiryPolicy? expiryPolicy,
    EvictionPolicy<K>? evictionPolicy,
    int maxEntries = 56,
  })  : _expiryPolicy =
            expiryPolicy ?? CreatedExpiryPolicy(Duration(seconds: 60)),
        _evictionPolicy = evictionPolicy ?? FifoEvictionPolicy<K>(),
        _maxEntries = maxEntries;

  /// Returns the number of valid (non-expired) entries in the cache.
  ///
  /// Time complexity: O(n) where n is the number of entries.
  int get size {
    _removeAllExpired();
    return _cache.length;
  }

  /// Returns all valid (non-expired) keys in the cache.
  ///
  /// Time complexity: O(n) where n is the number of entries.
  Iterable<K> get keys {
    _removeAllExpired();
    return _cache.keys;
  }

  /// Checks if the cache contains a valid entry for the given key.
  ///
  /// Returns false if the key doesn't exist or the entry has expired.
  /// Time complexity: O(1) average case.
  bool containsKey(K key) {
    final entry = _cache[key];
    if (entry == null) return false;

    if (_isExpired(entry)) {
      _removeEntry(key);
      return false;
    }

    return true;
  }

  /// Retrieves the value for the given key.
  ///
  /// Returns null if the key doesn't exist or the entry has expired.
  /// Updates the last access time and may update expiry based on the policy.
  /// Time complexity: O(1) average case.
  V? get(K key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (_isExpired(entry)) {
      _removeEntry(key);
      return null;
    }

    entry.markAccessed();
    _updateExpiryForAccess(entry);

    return entry.value;
  }

  /// Adds or updates an entry in the cache.
  ///
  /// If the cache is full and eviction policy is set, evicts an entry first.
  /// Time complexity: O(1) average case, O(n) when eviction is needed.
  void put(K key, V value) {
    final existingEntry = _cache[key];
    final isUpdate = existingEntry != null;

    if (isUpdate) {
      // Update existing entry
      final now = DateTime.now();
      existingEntry.markModified();
      _updateExpiryForUpdate(existingEntry);

      // Create new entry with updated value
      final newEntry = CacheEntry(
        value: value,
        createdAt: existingEntry.createdAt,
        lastAccessedAt: now,
        lastModifiedAt: now,
        expiryTime: existingEntry.expiryTime,
      );
      _cache[key] = newEntry;
    } else {
      // Add new entry
      // Check if we need to evict
      if (_maxEntries != null && _cache.length >= _maxEntries!) {
        _evictOne();
      }

      final duration = _expiryPolicy.getExpiryForCreation();
      final expiryTime = duration != null ? DateTime.now().add(duration) : null;

      _cache[key] = CacheEntry.now(
        value: value,
        expiryTime: expiryTime,
      );

      _evictionPolicy?.onEntryAdded(key);
    }
  }

  /// Removes the entry for the given key.
  ///
  /// Returns the value if the key existed and was not expired, null otherwise.
  /// Time complexity: O(1) average case.
  V? remove(K key) {
    final entry = _cache.remove(key);
    if (entry == null) return null;

    _evictionPolicy?.onEntryRemoved(key);

    if (_isExpired(entry)) return null;

    return entry.value;
  }

  /// Removes all entries from the cache.
  ///
  /// Time complexity: O(1).
  void clear() {
    _cache.clear();
    _evictionPolicy?.clear();
  }

  /// Retrieves multiple values for the given keys.
  ///
  /// Returns a map with the same keys, where values are null for missing or expired entries.
  /// Time complexity: O(m) where m is the number of keys.
  Map<K, V?> getAll(Iterable<K> keys) {
    final result = <K, V?>{};
    for (final key in keys) {
      result[key] = get(key);
    }
    return result;
  }

  /// Adds multiple entries to the cache.
  ///
  /// Time complexity: O(m) where m is the number of entries.
  void putAll(Map<K, V> entries) {
    for (final entry in entries.entries) {
      put(entry.key, entry.value);
    }
  }

  /// Removes multiple entries from the cache.
  ///
  /// Time complexity: O(m) where m is the number of keys.
  void removeAll(Iterable<K> keys) {
    for (final key in keys) {
      remove(key);
    }
  }

  /// Adds an entry only if the key doesn't exist or is expired.
  ///
  /// The [ifAbsent] function is only called if the key is not present.
  /// Returns the existing value if present and not expired, otherwise returns the new value.
  /// Time complexity: O(1) average case.
  V putIfAbsent(K key, V Function() ifAbsent) {
    final entry = _cache[key];

    if (entry != null && !_isExpired(entry)) {
      return entry.value;
    }

    final value = ifAbsent();
    put(key, value);
    return value;
  }

  /// Gets the current value and then replaces it with the new value.
  ///
  /// Returns the old value if it existed and was not expired, null otherwise.
  /// Time complexity: O(1) average case.
  V? getAndPut(K key, V value) {
    final oldValue = get(key);
    put(key, value);
    return oldValue;
  }

  /// Gets the current value and then removes the entry.
  ///
  /// Returns the value if it existed and was not expired, null otherwise.
  /// Time complexity: O(1) average case.
  V? getAndRemove(K key) {
    final value = get(key);
    remove(key);
    return value;
  }

  // Internal helper methods

  bool _isExpired(CacheEntry<V> entry) {
    return entry.isExpired;
  }

  void _updateExpiryForAccess(CacheEntry<V> entry) {
    final duration = _expiryPolicy.getExpiryForAccess();
    if (duration != null) {
      entry.expiryTime = DateTime.now().add(duration);
    }
  }

  void _updateExpiryForUpdate(CacheEntry<V> entry) {
    final duration = _expiryPolicy.getExpiryForUpdate();
    if (duration != null) {
      entry.expiryTime = DateTime.now().add(duration);
    }
  }

  void _removeEntry(K key) {
    _cache.remove(key);
    _evictionPolicy?.onEntryRemoved(key);
  }

  void _removeAllExpired() {
    final expiredKeys = <K>[];
    for (final entry in _cache.entries) {
      if (_isExpired(entry.value)) {
        expiredKeys.add(entry.key);
      }
    }
    for (final key in expiredKeys) {
      _removeEntry(key);
    }
  }

  void _evictOne() {
    if (_evictionPolicy == null) return;

    final keyToEvict = _evictionPolicy!.selectEntryToEvict();
    if (keyToEvict != null) {
      _cache.remove(keyToEvict);
    }
  }
}
