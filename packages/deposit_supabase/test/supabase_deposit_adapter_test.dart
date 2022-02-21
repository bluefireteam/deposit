import 'dart:io';

import 'package:deposit/deposit.dart';
import 'package:deposit_supabase/deposit_supabase.dart';
import 'package:supabase/supabase.dart';
import 'package:test/test.dart';

import 'mocks/supabase_server_mock.dart';

void main() {
  group('SupabaseDepositAdapter', () {
    late HttpServer supabaseMockServer;
    late SupabaseClient client;
    late SupabaseDepositAdapter adapter;

    setUp(() async {
      supabaseMockServer = await supabaseServerMock(
        tables: {
          'cars': [],
        },
      );
      client = SupabaseClient(
        'http://${supabaseMockServer.address.host}:${supabaseMockServer.port}',
        'supabaseKey',
      );
      adapter = SupabaseDepositAdapter(client);
    });

    tearDown(() async {
      await supabaseMockServer.close();
    });

    test('can be instantiated', () {
      expect(SupabaseDepositAdapter(client), isNotNull);
    });

    group('.add()', () {
      test('can add a single item', () async {
        await adapter.add(
          'cars',
          'id',
          <String, dynamic>{'brand': 'VW', 'model': 'Nivus'},
        );

        final result = await client.from('cars').select().execute();
        final data = (result.data as List).cast<Map>();

        expect(data.length, equals(1));
        expect(data.first['brand'], equals('VW'));
        expect(data.first['model'], equals('Nivus'));
      });
    });

    group('.by()', () {
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

      test('returns a list of items', () async {
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
        final result = await client.from('cars').insert({
          'id': 1,
          'brand': 'VW',
          'model': 'Nivus',
        }).execute();
        final data = result.data as Map<String, dynamic>;

        expect(
          await adapter.exists('cars', 'id', data['id'] as int),
          isTrue,
        );
      });
    });

    group('.getById()', () {
      test('returns an item by id', () async {
        final result = await client.from('cars').insert({
          'id': 1,
          'brand': 'VW',
          'model': 'Nivus',
        }).execute();
        final data = result.data as Map<String, dynamic>;

        expect(
          await adapter.getById('cars', 'id', data['id'] as int),
          isNotNull,
        );
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
      test('removes an item', () async {
        final data = await adapter.add('cars', 'id', <String, dynamic>{
          'id': 1,
          'brand': 'VW',
          'model': 'Nivus',
        });

        await adapter.remove('cars', 'id', data);

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
  });
}
