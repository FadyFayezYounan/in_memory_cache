import 'expiry_policy.dart';

/// An expiry policy where entries expire after a fixed duration from last access.
///
/// The expiry time is reset whenever the entry is accessed (read).
class AccessedExpiryPolicy implements ExpiryPolicy {
  final Duration duration;

  AccessedExpiryPolicy(this.duration);

  @override
  Duration? getExpiryForCreation() => duration;

  @override
  Duration? getExpiryForAccess() => duration;

  @override
  Duration? getExpiryForUpdate() => null;
}
