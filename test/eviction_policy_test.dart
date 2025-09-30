import 'package:in_memory_cache/in_memory_cache.dart';
import 'package:test/test.dart';

void main() {
  group('FifoEvictionPolicy', () {
    late FifoEvictionPolicy<String> policy;

    setUp(() {
      policy = FifoEvictionPolicy<String>();
    });

    test('evicts oldest entry first', () {
      policy.onEntryAdded('first');
      policy.onEntryAdded('second');
      policy.onEntryAdded('third');

      expect(policy.selectEntryToEvict(), equals('first'));
      expect(policy.selectEntryToEvict(), equals('second'));
      expect(policy.selectEntryToEvict(), equals('third'));
    });

    test('returns null when empty', () {
      expect(policy.selectEntryToEvict(), isNull);
    });

    test('handles entry removal', () {
      policy.onEntryAdded('first');
      policy.onEntryAdded('second');
      policy.onEntryAdded('third');

      policy.onEntryRemoved('second');

      expect(policy.selectEntryToEvict(), equals('first'));
      expect(policy.selectEntryToEvict(), equals('third'));
    });

    test('clear removes all entries', () {
      policy.onEntryAdded('first');
      policy.onEntryAdded('second');

      policy.clear();

      expect(policy.selectEntryToEvict(), isNull);
    });
  });

  group('FiloEvictionPolicy', () {
    late FiloEvictionPolicy<String> policy;

    setUp(() {
      policy = FiloEvictionPolicy<String>();
    });

    test('evicts newest entry first', () {
      policy.onEntryAdded('first');
      policy.onEntryAdded('second');
      policy.onEntryAdded('third');

      expect(policy.selectEntryToEvict(), equals('third'));
      expect(policy.selectEntryToEvict(), equals('second'));
      expect(policy.selectEntryToEvict(), equals('first'));
    });

    test('returns null when empty', () {
      expect(policy.selectEntryToEvict(), isNull);
    });

    test('handles entry removal', () {
      policy.onEntryAdded('first');
      policy.onEntryAdded('second');
      policy.onEntryAdded('third');

      policy.onEntryRemoved('second');

      expect(policy.selectEntryToEvict(), equals('third'));
      expect(policy.selectEntryToEvict(), equals('first'));
    });

    test('clear removes all entries', () {
      policy.onEntryAdded('first');
      policy.onEntryAdded('second');

      policy.clear();

      expect(policy.selectEntryToEvict(), isNull);
    });
  });
}
