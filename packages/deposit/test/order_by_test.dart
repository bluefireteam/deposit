import 'package:deposit/deposit.dart';
import 'package:test/test.dart';

void main() {
  group('OrderBy', () {
    test('can be instantiated', () {
      expect(OrderBy('key'), isNotNull);
    });
  });
}
