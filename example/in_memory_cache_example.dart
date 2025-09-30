import 'package:in_memory_cache/in_memory_cache.dart';

void main() {
  // Create a simple cache
  final cache = Cache<String, String>(
    expiryPolicy: CreatedExpiryPolicy(Duration(minutes: 5)),
    maxEntries: 100,
    evictionPolicy: FifoEvictionPolicy<String>(),
  );

  // Add some entries
  cache.put('name', 'John Doe');
  cache.put('email', 'john@example.com');
  cache.put('role', 'developer');

  // Retrieve values
  print('Name: ${cache.get('name')}');
  print('Email: ${cache.get('email')}');
  print('Role: ${cache.get('role')}');

  // Display cache info
  print('\nCache size: ${cache.size}');
  print('Cache keys: ${cache.keys}');

  // Demonstrate batch operations
  final userData = cache.getAll(['name', 'email', 'role']);
  print('\nUser data: $userData');
}
