import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deposit_firestore/deposit_firestore.dart';

void main() {
  group('FirestoreDepositAdapter', () {
    late FirebaseFirestore instance;
    late FirestoreDepositAdapter adapter;

    setUp(() {
      instance = FakeFirebaseFirestore();
      adapter = FirestoreDepositAdapter(firestore: instance);
    });

    test('can be instantiated', () {
      expect(
        FirestoreDepositAdapter(firestore: instance),
        isNotNull,
      );
    });

    group('.add()', () {
      test('can add a doc', () async {
        await adapter.add(
          'cars',
          'id',
          {
            'brand': 'VW',
            'model': 'Nivus',
          },
        );

        final snapshot = await instance.collection('cars').get();

        expect(snapshot.docs.length, equals(1));
        expect(snapshot.docs.first.id, isA<String>());
        expect(snapshot.docs.first['brand'], equals('VW'));
        expect(snapshot.docs.first['model'], equals('Nivus'));
      });
    });

    group('.addAll()', () {
      test('can add multiple items', () async {
        await adapter.addAll(
          'cars',
          'id',
          [
            <String, dynamic>{'brand': 'VW', 'model': 'Nivus'},
            <String, dynamic>{'brand': 'VW', 'model': 'Virtus'},
          ],
        );

        final snapshot = await instance.collection('cars').get();

        expect(snapshot.docs.length, equals(2));
        expect(snapshot.docs[0]['brand'], equals('VW'));
        expect(snapshot.docs[0]['model'], equals('Nivus'));
        expect(snapshot.docs[1]['brand'], equals('VW'));
        expect(snapshot.docs[1]['model'], equals('Virtus'));
      });
    });

    group('.by()', () {
      setUp(() async {
        await Future.wait([
          instance.collection('cars').add({
            'brand': 'VW',
            'model': 'Nivus',
          }),
          instance.collection('cars').add({
            'brand': 'VW',
            'model': 'Virtus',
          }),
          instance.collection('cars').add({
            'brand': 'GM',
            'model': 'Onix',
          }),
        ]);
      });

      test('returns a list of docs', () async {
        final list = await adapter.by('cars', 'brand', 'VW');
        expect(list.length, equals(2));
      });

      test('returns an empty list', () async {
        final result = await adapter.by('cars', 'brand', 'Toyota');
        expect(result.length, equals(0));
      });
    });

    group('.exists()', () {
      group('using the id primary key', () {
        test('returns true when a doc is in the db', () async {
          final snapshot = await instance.collection('cars').add({
            'brand': 'VW',
            'model': 'Nivus',
          });

          expect(
            await adapter.exists('cars', 'id', snapshot.id),
            isTrue,
          );
        });
      });

      group('using a field different than the id', () {
        test('returns true when a doc is in the db', () async {
          await instance.collection('cars').add({
            'brand': 'VW',
            'model': 'Nivus',
          });

          expect(
            await adapter.exists('cars', 'brand', 'VW'),
            isTrue,
          );
        });
      });
    });

    group('.getById()', () {
      test('returns a doc by id', () async {
        final snapshot = await instance.collection('cars').add({
          'brand': 'VW',
          'model': 'Nivus',
        });

        expect(
          await adapter.getById('cars', 'id', snapshot.id),
          isNotNull,
        );
      });
    });

    group('.page()', () {
      test('throws unsupported', () {
        expect(
          () => adapter.page('cars', limit: 1, skip: 0),
          throwsA(isA<UnsupportedError>()),
        );
      });
    });

    group('.remove()', () {
      test('removes the doc', () async {
        final data = await adapter.add('cars', 'id', {
          'brand': 'VW',
          'model': 'Nivus',
        });

        await adapter.remove('cars', 'id', data);

        expect(
          await adapter.exists('cars', 'brand', 'VW'),
          isFalse,
        );

        // Just making sure the adapter didn't accidentally create
        // a new doc instead of deleting one.
        final docs = await adapter.by('cars', 'brand', 'VW');
        expect(docs.length, equals(0));
      });
    });

    group('.removeAll()', () {
      test('removes multiple items', () async {
        final data = await adapter.addAll(
          'cars',
          'id',
          [
            <String, dynamic>{'brand': 'VW', 'model': 'Nivus'},
            <String, dynamic>{'brand': 'VW', 'model': 'Virtus'},
          ],
        );

        await adapter.removeAll('cars', 'id', data);

        expect(
          await adapter.exists('cars', 'brand', 'VW'),
          isFalse,
        );

        // Just making sure the adapter didn't accidentally create
        // new docs instead of deleting one.
        final docs = await adapter.by('cars', 'brand', 'VW');
        expect(docs.length, equals(0));
      });
    });

    group('.update()', () {
      test('updates a doc', () async {
        final value = await adapter.add('cars', 'id', {
          'brand': 'VW',
          'model': 'Virtus',
        });

        await adapter.update('cars', 'id', {
          'id': value['id'],
          'brand': 'VW',
          'model': 'Nivus',
        });

        expect(
          await adapter.exists('cars', 'model', 'Nivus'),
          isTrue,
        );

        // Just making sure the adapter didn't accidentally created
        // a new doc instead of updating one.
        final docs = await adapter.by('cars', 'brand', 'VW');
        expect(docs.length, equals(1));
      });
    });

    group('.updateAll()', () {
      test('updates multiple items', () async {
        final data = await adapter.addAll(
          'cars',
          'id',
          [
            <String, dynamic>{'brand': 'VW', 'model': 'Nivus'},
            <String, dynamic>{'brand': 'VW', 'model': 'Virtus'},
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
            'model': 'Ayigo',
          },
        ]);

        expect(
          await adapter.exists('cars', 'model', 'Ayigo'),
          isTrue,
        );

        // Just making sure the adapter didn't accidentally created
        // new docs instead of updating one.
        final docs = await adapter.by('cars', 'brand', 'Toyota');
        expect(docs.length, equals(2));
      });
    });
  });
}
