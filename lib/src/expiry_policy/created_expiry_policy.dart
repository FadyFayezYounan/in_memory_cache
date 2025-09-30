import 'expiry_policy.dart';

/// An expiry policy where entries expire after a fixed duration from creation.
///
/// The expiry time is set when the entry is created and does not change
/// on subsequent access or update operations.
class CreatedExpiryPolicy implements ExpiryPolicy {
  final Duration duration;

  CreatedExpiryPolicy(this.duration);

  @override
  Duration? getExpiryForCreation() => duration;

  @override
  Duration? getExpiryForAccess() => null;

  @override
  Duration? getExpiryForUpdate() => null;
}
