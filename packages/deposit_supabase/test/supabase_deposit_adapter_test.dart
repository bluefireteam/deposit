import 'dart:io';

import 'package:deposit_supabase/deposit_supabase.dart';
import 'package:supabase/supabase.dart';
import 'package:test/test.dart';

import 'mocks/supabase_server_mock.dart';

void main() {
  group('SupabaseDepositAdapter', () {
    late HttpServer supbaseMockServer;
    late SupabaseClient client;
    late SupabaseDepositAdapter adapter;

    setUp(() async {
      supbaseMockServer = await supabaseServerMock(
        tables: {
          'cars': [],
        },
      );
      client = SupabaseClient(
        'http://${supbaseMockServer.address.host}:${supbaseMockServer.port}',
        'supabaseKey',
      );
      adapter = SupabaseDepositAdapter(client);
    });

    tearDown(() async {
      await supbaseMockServer.close();
    });

    test('should be instantiated', () {
      expect(SupabaseDepositAdapter(client), isNotNull);
    });

    group('.add()', () {
      test('should add a single item', () async {
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
      test('should return an item by id', () async {
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

    group('.page()', () {});

    group('.remove()', () {
      test('should remove an item from the db', () async {
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
      test('should update an item in the db', () async {
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
