import 'package:deposit/deposit.dart';
import 'package:test/test.dart';

void main() {
  group('MemoryDepositAdapter', () {
    late MemoryDepositAdapter adapter;
    const tableName = 'test_table';
    const primaryColumn = 'id';

    setUp(() {
      adapter = MemoryDepositAdapter();
    });

    group('.add()', () {
      test('should add a single item', () async {
        // Arrange
        final data = {'key': 'value'};

        // Act
        final result = await adapter.add(tableName, primaryColumn, data);

        // Assert
        expect(result['id'], equals(1));
        expect(result['key'], equals(data['key']));
      });
    });

    group('.by()', () {
      setUp(() async {
        for (var i = 0; i < 5; i++) {
          await adapter.add(
            tableName,
            primaryColumn,
            <String, dynamic>{'key': i},
          );
        }
      });

      test('should return a list with a single item', () async {
        // Act
        final result = await adapter.by(tableName, 'key', 2);

        // Assert
        expect(result.length, equals(1));
        expect(result.first['id'], equals(3));
        expect(result.first['key'], equals(2));
      });

      test('should return an empty list', () async {
        // Act
        final result = await adapter.by(tableName, 'key', 6);

        // Assert
        expect(result.length, equals(0));
      });
    });

    group('.getById()', () {
      setUp(() async {
        for (var i = 0; i < 5; i++) {
          await adapter.add(
            tableName,
            primaryColumn,
            <String, dynamic>{'key': i},
          );
        }
      });

      test('should return a single item', () async {
        // Act
        final result = await adapter.getById(tableName, primaryColumn, 2);

        // Assert
        expect(result['id'], equals(2));
        expect(result['key'], equals(1));
      });

      test('should throw an exception if no item is found', () async {
        // Act
        final result = adapter.getById(tableName, primaryColumn, 6);

        // Assert
        expect(result, throwsStateError);
      });
    });
  });
}
