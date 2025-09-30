/// Abstract base class for eviction policies.
///
/// Defines how entries are selected for eviction when the cache reaches its maximum size.
abstract class EvictionPolicy<K> {
  /// Called when a new entry is added to the cache.
  void onEntryAdded(K key);

  /// Selects an entry to evict from the cache.
  ///
  /// Returns the key of the entry to evict, or null if no entry can be evicted.
  K? selectEntryToEvict();

  /// Called when an entry is removed from the cache.
  void onEntryRemoved(K key);

  /// Clears all tracking data.
  void clear();
}
