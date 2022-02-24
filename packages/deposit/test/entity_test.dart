import 'package:deposit/deposit.dart';
import 'package:test/test.dart';

class TestEntity extends Entity {
  @override
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{};
  }
}

void main() {
  group('Entity', () {
    test('can be instantiated', () {
      expect(TestEntity(), isNotNull);
    });
  });
}
