import 'eviction_policy.dart';

/// First-In-Last-Out (LIFO/Stack) eviction policy.
///
/// Evicts the most recently added entry when the cache is full.
class FiloEvictionPolicy<K> implements EvictionPolicy<K> {
  final List<K> _stack = [];

  @override
  void onEntryAdded(K key) {
    _stack.add(key);
  }

  @override
  K? selectEntryToEvict() {
    if (_stack.isEmpty) return null;
    return _stack.removeLast();
  }

  @override
  void onEntryRemoved(K key) {
    _stack.remove(key);
  }

  @override
  void clear() {
    _stack.clear();
  }
}
