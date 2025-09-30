import 'expiry_policy.dart';

/// An expiry policy where entries expire after a fixed duration from any operation.
///
/// The expiry time is reset on any operation: creation, access, or update.
class TouchedExpiryPolicy implements ExpiryPolicy {
  final Duration duration;

  TouchedExpiryPolicy(this.duration);

  @override
  Duration? getExpiryForCreation() => duration;

  @override
  Duration? getExpiryForAccess() => duration;

  @override
  Duration? getExpiryForUpdate() => duration;
}
