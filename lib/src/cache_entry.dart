/// Represents a cache entry with value and metadata.
class CacheEntry<V> {
  /// The cached value
  final V value;

  /// When the entry was created
  final DateTime createdAt;

  /// When the entry was last accessed
  DateTime lastAccessedAt;

  /// When the entry was last modified
  DateTime lastModifiedAt;

  /// When the entry expires (null means no expiry)
  DateTime? expiryTime;

  CacheEntry({
    required this.value,
    required this.createdAt,
    required this.lastAccessedAt,
    required this.lastModifiedAt,
    this.expiryTime,
  });

  /// Creates a new cache entry with the current timestamp
  factory CacheEntry.now({
    required V value,
    DateTime? expiryTime,
  }) {
    final now = DateTime.now();
    return CacheEntry(
      value: value,
      createdAt: now,
      lastAccessedAt: now,
      lastModifiedAt: now,
      expiryTime: expiryTime,
    );
  }

  /// Updates the last accessed timestamp
  void markAccessed() {
    lastAccessedAt = DateTime.now();
  }

  /// Updates the last modified timestamp
  void markModified() {
    lastModifiedAt = DateTime.now();
  }

  /// Checks if the entry has expired
  bool get isExpired {
    if (expiryTime == null) return false;
    return DateTime.now().isAfter(expiryTime!);
  }
}
