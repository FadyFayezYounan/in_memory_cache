/// Abstract base class for expiry policies.
///
/// Defines how cache entries expire based on different operations.
abstract class ExpiryPolicy {
  /// Returns the duration after which an entry should expire when created.
  ///
  /// Returns null if the entry should not expire on creation.
  Duration? getExpiryForCreation();

  /// Returns the duration after which an entry should expire when accessed.
  ///
  /// Returns null if the entry should not update expiry on access.
  Duration? getExpiryForAccess();

  /// Returns the duration after which an entry should expire when updated.
  ///
  /// Returns null if the entry should not update expiry on update.
  Duration? getExpiryForUpdate();
}
