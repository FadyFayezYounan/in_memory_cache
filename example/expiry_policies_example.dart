import 'package:in_memory_cache/in_memory_cache.dart';

void main() async {
  print('=== Eternal Expiry Policy ===');
  eternalExample();

  print('\n=== Created Expiry Policy ===');
  await createdExample();

  print('\n=== Accessed Expiry Policy ===');
  await accessedExample();

  print('\n=== Modified Expiry Policy ===');
  await modifiedExample();

  print('\n=== Touched Expiry Policy ===');
  await touchedExample();
}

void eternalExample() {
  // Entries never expire
  final cache = Cache<String, String>(
    expiryPolicy: EternalExpiryPolicy(),
  );

  cache.put('eternal', 'This never expires');
  print('Value: ${cache.get('eternal')}');
}

Future<void> createdExample() async {
  // Entries expire 2 seconds after creation
  final cache = Cache<String, String>(
    expiryPolicy: CreatedExpiryPolicy(Duration(seconds: 2)),
  );

  cache.put('temp', 'Expires in 2 seconds');
  print('Immediately: ${cache.get('temp')}'); // Found

  await Future.delayed(Duration(seconds: 1));
  print('After 1 second: ${cache.get('temp')}'); // Still found

  await Future.delayed(Duration(seconds: 2));
  print('After 3 seconds: ${cache.get('temp')}'); // null (expired)
}

Future<void> accessedExample() async {
  // Entries expire 2 seconds after last access
  final cache = Cache<String, String>(
    expiryPolicy: AccessedExpiryPolicy(Duration(seconds: 2)),
  );

  cache.put('accessed', 'Expires 2s after access');
  print('Initial: ${cache.get('accessed')}'); // Found

  await Future.delayed(Duration(seconds: 1));
  print('After 1s: ${cache.get('accessed')}'); // Found, resets expiry

  await Future.delayed(Duration(seconds: 1));
  print(
      'After 2s: ${cache.get('accessed')}'); // Still found (last access was 1s ago)

  await Future.delayed(Duration(seconds: 3));
  print('After 5s total: ${cache.get('accessed')}'); // null (expired)
}

Future<void> modifiedExample() async {
  // Entries expire 2 seconds after last modification
  final cache = Cache<String, String>(
    expiryPolicy: ModifiedExpiryPolicy(Duration(seconds: 2)),
  );

  cache.put('modified', 'v1');
  print('Initial: ${cache.get('modified')}'); // v1

  await Future.delayed(Duration(seconds: 1));
  cache.put('modified', 'v2'); // Reset expiry
  print('Modified: ${cache.get('modified')}'); // v2

  await Future.delayed(Duration(seconds: 1));
  print('1s after modify: ${cache.get('modified')}'); // v2 (still valid)

  await Future.delayed(Duration(seconds: 2));
  print('3s after modify: ${cache.get('modified')}'); // null (expired)
}

Future<void> touchedExample() async {
  // Entries expire 2 seconds after any operation
  final cache = Cache<String, String>(
    expiryPolicy: TouchedExpiryPolicy(Duration(seconds: 2)),
  );

  cache.put('touched', 'v1');
  await Future.delayed(Duration(seconds: 1));

  cache.get('touched'); // Resets expiry
  await Future.delayed(Duration(seconds: 1));

  cache.put('touched', 'v2'); // Resets expiry again
  await Future.delayed(Duration(seconds: 1));

  print('Still valid: ${cache.get('touched')}'); // v2 (still valid)

  await Future.delayed(Duration(seconds: 3));
  print('Expired: ${cache.get('touched')}'); // null (expired)
}
