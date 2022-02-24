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

    group('MemoryDepositAdapter()', () {
      test('can be instantiated', () {
        expect(MemoryDepositAdapter(), isNotNull);
      });

      test('can be instantiated with memory', () {
        expect(MemoryDepositAdapter(memory: {}), isNotNull);
      });
    });

    group('.add()', () {
      test('adds a single item', () async {
        await adapter.add(
          'cars',
          'id',
          <String, dynamic>{'brand': 'VW', 'model': 'Nivus'},
        );

        final result = memory['cars'];

        expect(result!.length, equals(1));
        expect(result.first['brand'], equals('VW'));
        expect(result.first['model'], equals('Nivus'));
      });
    });

    group('.addAll()', () {
      test('adds multiple items', () async {
        await adapter.addAll(
          'cars',
          'id',
          [
            <String, dynamic>{'brand': 'VW', 'model': 'Nivus'},
            <String, dynamic>{'brand': 'VW', 'model': 'Virtus'},
          ],
        );

        final result = memory['cars'];

        expect(result!.length, equals(2));
        expect(result[0]['brand'], equals('VW'));
        expect(result[0]['model'], equals('Nivus'));
        expect(result[1]['brand'], equals('VW'));
        expect(result[1]['model'], equals('Virtus'));
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

      test('returns a list with a single item', () async {
        final list = await adapter.by('cars', 'brand', 'VW');
        expect(list.length, equals(2));
      });

      test('returns an empty list', () async {
        final result = await adapter.by('cars', 'brand', 'Toyota');
        expect(result.length, equals(0));
      });
    });

    group('.exists()', () {
      test('returns true when an item is in the db', () async {
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
      test('returns an item by id', () async {
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

      test('throws an exception if no item is found', () async {
        final result = adapter.getById('cars', 'id', 2);

        expect(result, throwsStateError);
      });
    });

    group('.page()', () {
      setUp(() async {
        await Future.wait([
          adapter.add('cars', 'id', <String, dynamic>{
            'brand': 'VW',
            'model': 'Nivus',
          }),
          adapter.add('cars', 'id', <String, dynamic>{
            'brand': 'VW',
            'model': 'Virtus',
          }),
          adapter.add('cars', 'id', <String, dynamic>{
            'brand': 'GM',
            'model': 'Onix',
          })
        ]);
      });

      test('returns a paginated list of items', () async {
        final result = await adapter.page('cars', limit: 2, skip: 1);

        expect(result.length, equals(2));
      });

      test('returns a paginated list of items', () async {
        final result = await adapter.page('cars', limit: 2, skip: 1);

        expect(result.length, equals(2));
      });

      test('returns a paginated list of items ordered by brand ascending',
          () async {
        final result = await adapter.page(
          'cars',
          limit: 2,
          skip: 1,
          orderBy: OrderBy('brand', ascending: true),
        );

        expect(result.length, equals(2));
        expect(result[0]['brand'], equals('VW'));
        expect(result[1]['brand'], equals('VW'));
      });

      test('returns a paginated list of items ordered by brand descending',
          () async {
        final result = await adapter.page(
          'cars',
          limit: 2,
          skip: 1,
          orderBy: OrderBy('brand'),
        );

        expect(result.length, equals(2));
        expect(result[0]['brand'], equals('VW'));
        expect(result[1]['brand'], equals('GM'));
      });
    });

    group('.remove()', () {
      test('removes an item from the db', () async {
        final data = await adapter.add('cars', 'id', <String, dynamic>{
          'brand': 'VW',
          'model': 'Nivus',
        });

        await adapter.remove('cars', 'id', data);

        expect(await adapter.exists('cars', 'id', data['id'] as int), isFalse);
      });
    });

    group('.removeAll()', () {
      test('removes multiple items', () async {
        final data = await adapter.addAll(
          'cars',
          'id',
          [
            <String, dynamic>{'id': 1, 'brand': 'VW', 'model': 'Nivus'},
            <String, dynamic>{'id': 2, 'brand': 'VW', 'model': 'Virtus'},
          ],
        );

        await adapter.removeAll('cars', 'id', data);

        final result = await adapter.by('cars', 'model', 'Nivus');

        expect(result.length, equals(0));
      });
    });

    group('.update()', () {
      test('updates an item', () async {
        final data = await adapter.add('cars', 'id', <String, dynamic>{
          'id': 1,
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

    group('.updateAll()', () {
      test('updates multiple items', () async {
        final data = await adapter.addAll(
          'cars',
          'id',
          [
            <String, dynamic>{'id': 1, 'brand': 'VW', 'model': 'Nivus'},
            <String, dynamic>{'id': 2, 'brand': 'VW', 'model': 'Virtus'},
          ],
        );

        await adapter.updateAll('cars', 'id', [
          <String, dynamic>{
            'id': data[0]['id'],
            'brand': 'Toyota',
            'model': 'Yaris',
          },
          <String, dynamic>{
            'id': data[1]['id'],
            'brand': 'Toyota',
            'model': 'Aygo',
          },
        ]);

        final result = await adapter.by('cars', 'brand', 'Toyota');

        expect(result.length, equals(2));
        expect(result[0]['id'], equals(data[0]['id']));
      });
    });
  });
}
