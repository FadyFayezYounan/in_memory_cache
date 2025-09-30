import 'expiry_policy.dart';

/// An expiry policy where entries expire after a fixed duration from last modification.
///
/// The expiry time is reset whenever the entry is modified (updated).
class ModifiedExpiryPolicy implements ExpiryPolicy {
  final Duration duration;

  ModifiedExpiryPolicy(this.duration);

  @override
  Duration? getExpiryForCreation() => duration;

  @override
  Duration? getExpiryForAccess() => null;

  @override
  Duration? getExpiryForUpdate() => duration;
}
