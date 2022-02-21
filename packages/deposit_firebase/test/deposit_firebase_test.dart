import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deposit_firebase/deposit_firebase.dart';

void main() {
  group('FirebaseDepositAdapter', () {
    late FirebaseFirestore instance;
    late FirebaseDepositAdapter adapter;

    setUp(() {
      instance = FakeFirebaseFirestore();
      adapter = FirebaseDepositAdapter(firestore: instance);
    });

    test('can be instantiated', () {
      expect(
        FirebaseDepositAdapter(firestore: instance),
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
        expect(snapshot.docs.first['brand'], equals('VW'));
        expect(snapshot.docs.first['model'], equals('Nivus'));
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
  });
}
