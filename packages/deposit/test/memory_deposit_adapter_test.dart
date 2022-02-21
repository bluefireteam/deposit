import 'package:deposit/deposit.dart';
import 'package:test/test.dart';

void main() {
  group('MemoryDepositAdapter', () {
    late Map<String, List<Map<String, dynamic>>> memory;
    late MemoryDepositAdapter adapter;

    setUp(() {
      memory = {'cars': []};
      adapter = MemoryDepositAdapter(memory: memory);
    });

    group('.add()', () {
      test('should add a single item', () async {
        await adapter.add(
          'cars',
          'id',
          <String, dynamic>{'brand': 'VW', 'model': 'Nivus'},
        );

        final result = memory['cars'];

        expect(result, isNotNull);
        expect(result?.length, equals(1));
        expect(result?.first['brand'], equals('VW'));
        expect(result?.first['model'], equals('Nivus'));
      });
    });

    group('.by()', () {
      setUp(() {
        memory['cars']?.addAll([
          <String, dynamic>{
            'brand': 'VW',
            'model': 'Nivus',
          },
          <String, dynamic>{
            'brand': 'VW',
            'model': 'Virtus',
          },
          <String, dynamic>{
            'brand': 'GM',
            'model': 'Onix',
          }
        ]);
      });

      test('should return a list with a single item', () async {
        final list = await adapter.by('cars', 'brand', 'VW');
        expect(list.length, equals(2));
      });

      test('should return an empty list', () async {
        final result = await adapter.by('cars', 'brand', 'Toyota');
        expect(result.length, equals(0));
      });
    });

    group('.exists()', () {
      test('should return true when an item is in the db', () async {
        memory['cars']?.add(<String, dynamic>{
          'id': 1,
          'brand': 'VW',
          'model': 'Nivus',
        });

        expect(
          await adapter.exists('cars', 'id', 1),
          isTrue,
        );
      });
    });

    group('.getById()', () {
      test('should return an item by id', () async {
        memory['cars']?.add(<String, dynamic>{
          'id': 1,
          'brand': 'VW',
          'model': 'Nivus',
        });

        expect(
          await adapter.getById('cars', 'id', 1),
          isNotNull,
        );
      });

      test('should throw an exception if no item is found', () async {
        final result = adapter.getById('cars', 'id', 2);

        expect(result, throwsStateError);
      });
    });

    group('.page()', () {});

    group('.remove()', () {
      test('should remove an item from the db', () async {
        final data = await adapter.add('cars', 'id', <String, dynamic>{
          'brand': 'VW',
          'model': 'Nivus',
        });

        await adapter.remove('cars', 'id', data);

        expect(await adapter.exists('cars', 'id', data['id'] as int), isFalse);
      });
    });

    group('.update()', () {
      test('should update an item in the db', () async {
        final data = await adapter.add('cars', 'id', <String, dynamic>{
          'brand': 'VW',
          'model': 'Virtus',
        });

        await adapter.update('cars', 'id', <String, dynamic>{
          'id': data['id'],
          'brand': 'VW',
          'model': 'Nivus',
        });

        final result = await adapter.by('cars', 'model', 'Nivus');

        expect(result.length, equals(1));
        expect(result.first['id'], equals(data['id']));
      });
    });
  });
}
