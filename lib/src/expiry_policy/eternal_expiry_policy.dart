import 'expiry_policy.dart';

/// An expiry policy where entries never expire.
class EternalExpiryPolicy implements ExpiryPolicy {
  @override
  Duration? getExpiryForCreation() => null;

  @override
  Duration? getExpiryForAccess() => null;

  @override
  Duration? getExpiryForUpdate() => null;
}
