/// A flexible in-memory caching solution with configurable expiry and eviction policies.
///
/// This library provides a feature-rich cache implementation with:
/// - Multiple expiry policies (eternal, created, accessed, modified, touched)
/// - Eviction policies (FIFO, FILO)
/// - Configurable maximum entries
/// - Batch operations
/// - Atomic operations
library;

// Core cache
export 'src/cache.dart';
export 'src/cache_entry.dart';

// Expiry policies
export 'src/expiry_policy/expiry_policy.dart';
export 'src/expiry_policy/eternal_expiry_policy.dart';
export 'src/expiry_policy/created_expiry_policy.dart';
export 'src/expiry_policy/accessed_expiry_policy.dart';
export 'src/expiry_policy/modified_expiry_policy.dart';
export 'src/expiry_policy/touched_expiry_policy.dart';

// Eviction policies
export 'src/eviction_policy/eviction_policy.dart';
export 'src/eviction_policy/fifo_eviction_policy.dart';
export 'src/eviction_policy/filo_eviction_policy.dart';
