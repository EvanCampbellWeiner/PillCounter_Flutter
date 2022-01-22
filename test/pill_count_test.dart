import 'package:flutter_test/flutter_test.dart';
import 'package:pillcounter_flutter/pillinformation.dart';

void main() {
  group('Pill Information Count:', () {
    test('starts at 0', () {
      expect(
          PillInformation(din: '0000019', description: 'count = 0').count, 0);
    });
    test('can be incremented', () {
      final pillinfo =
          PillInformation(din: '0000019', description: 'test description');
      pillinfo.increment();
      expect(pillinfo.count, 1);
    });
    test('can be decremented', () {
      final pillinfo =
          PillInformation(din: '0000019', description: 'test description');
      pillinfo.decrement();
      expect(pillinfo.count, -1);
    });
  });
}
