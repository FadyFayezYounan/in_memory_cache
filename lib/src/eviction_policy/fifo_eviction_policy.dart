import 'dart:collection';
import 'eviction_policy.dart';

/// First-In-First-Out eviction policy.
///
/// Evicts the oldest (first added) entry when the cache is full.
class FifoEvictionPolicy<K> implements EvictionPolicy<K> {
  final Queue<K> _queue = Queue<K>();

  @override
  void onEntryAdded(K key) {
    _queue.add(key);
  }

  @override
  K? selectEntryToEvict() {
    if (_queue.isEmpty) return null;
    return _queue.removeFirst();
  }

  @override
  void onEntryRemoved(K key) {
    _queue.remove(key);
  }

  @override
  void clear() {
    _queue.clear();
  }
}
