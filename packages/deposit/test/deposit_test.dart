import 'package:deposit/deposit.dart';
import 'package:test/test.dart';

class CarEntity extends Entity {
  CarEntity({
    this.id,
    required this.brand,
    required this.model,
  });

  factory CarEntity.fromJSON(Map<String, dynamic> data) {
    return CarEntity(
      id: data['id'] as int?,
      brand: data['brand'] as String,
      model: data['model'] as String,
    );
  }

  final int? id;

  String brand;

  String model;

  @override
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'id': id,
      'brand': brand,
      'model': model,
    };
  }
}

void main() {
  group('Deposit', () {
    late Deposit<CarEntity, int> deposit;

    setUp(() {
      deposit = Deposit<CarEntity, int>(
        'cars',
        CarEntity.fromJSON,
        adapter: MemoryDepositAdapter(),
      );
    });

    test('can be instantiated', () {
      final deposit = Deposit<CarEntity, int>(
        'cars',
        CarEntity.fromJSON,
        adapter: MemoryDepositAdapter(),
      );

      expect(deposit, isNotNull);
      expect(deposit.table, 'cars');
    });

    test('can be instantiated using default adapter', () {
      Deposit.defaultAdapter = MemoryDepositAdapter();

      final deposit = Deposit<CarEntity, int>(
        'cars',
        CarEntity.fromJSON,
      );

      expect(deposit, isNotNull);
      expect(deposit.table, 'cars');
    });

    group('.add()', () {
      test('can add a single item', () async {
        await deposit.add(CarEntity(brand: 'VW', model: 'Nivus'));

        final result = await deposit.page(limit: 10, skip: 0);

        expect(result.length, equals(1));
        expect(result.first.brand, equals('VW'));
        expect(result.first.model, equals('Nivus'));
      });
    });

    group('.addAll()', () {
      test('add multiple items', () async {
        await deposit.addAll([
          CarEntity(brand: 'VW', model: 'Nivus'),
          CarEntity(brand: 'VW', model: 'Virtus'),
        ]);

        final result = await deposit.page(limit: 10, skip: 0);

        expect(result.length, equals(2));
        expect(result[0].brand, equals('VW'));
        expect(result[0].model, equals('Nivus'));
        expect(result[1].brand, equals('VW'));
        expect(result[1].model, equals('Virtus'));
      });
    });

    group('.by()', () {
      setUp(() async {
        await Future.wait([
          deposit.add(CarEntity(brand: 'VW', model: 'Nivus')),
          deposit.add(CarEntity(brand: 'VW', model: 'Virtus')),
          deposit.add(CarEntity(brand: 'GM', model: 'Onix'))
        ]);
      });

      test('returns a list of items', () async {
        final list = await deposit.by('brand', 'VW');
        expect(list.length, equals(2));
      });

      test('returns an empty list', () async {
        final result = await deposit.by('brand', 'Toyota');
        expect(result.length, equals(0));
      });
    });

    group('.exists()', () {
      test('returns true when an item is in the db', () async {
        final data = await deposit.add(CarEntity(brand: 'VW', model: 'Nivus'));

        expect(await deposit.exists(data.id!), isTrue);
      });
    });

    group('.getById()', () {
      test('returns an item by id', () async {
        final data = await deposit.add(CarEntity(brand: 'VW', model: 'Nivus'));

        expect(await deposit.getById(data.id!), isA<CarEntity>());
      });
    });

    group('.page()', () {
      setUp(() async {
        await Future.wait([
          deposit.add(CarEntity(brand: 'VW', model: 'Nivus')),
          deposit.add(CarEntity(brand: 'VW', model: 'Virtus')),
          deposit.add(CarEntity(brand: 'GM', model: 'Onix'))
        ]);
      });

      test('returns a paginated list of items', () async {
        final result = await deposit.page(limit: 2, skip: 1);

        expect(result.length, equals(2));
      });

      test('returns a paginated list of items', () async {
        final result = await deposit.page(limit: 2, skip: 1);

        expect(result.length, equals(2));
      });

      test('returns a paginated list of items ordered by brand ascending',
          () async {
        final result = await deposit.page(
          limit: 2,
          skip: 1,
          orderBy: OrderBy('brand', ascending: true),
        );

        expect(result.length, equals(2));
        expect(result[0].brand, equals('VW'));
        expect(result[1].brand, equals('VW'));
      });

      test('returns a paginated list of items ordered by brand descending',
          () async {
        final result = await deposit.page(
          limit: 2,
          skip: 1,
          orderBy: OrderBy('brand'),
        );

        expect(result.length, equals(2));
        expect(result[0].brand, equals('VW'));
        expect(result[1].brand, equals('GM'));
      });
    });

    group('.remove()', () {
      test('removes an item', () async {
        final data = await deposit.add(
          CarEntity(brand: 'VW', model: 'Nivus'),
        );

        await deposit.remove(data);

        final result = await deposit.by('model', 'Nivus');

        expect(result.length, equals(0));
      });
    });

    group('.removeAll()', () {
      test('removes multiple items', () async {
        final data = await deposit.addAll([
          CarEntity(brand: 'VW', model: 'Nivus'),
          CarEntity(brand: 'VW', model: 'Virtus'),
        ]);

        await deposit.removeAll(data);

        final result = await deposit.by('model', 'Nivus');

        expect(result.length, equals(0));
      });
    });

    group('.update()', () {
      test('updates an item', () async {
        final data = await deposit.add(
          CarEntity(brand: 'VW', model: 'Virtus'),
        );

        await deposit.update(data..model = 'Nivus');

        final result = await deposit.by('model', 'Nivus');

        expect(result.length, equals(1));
        expect(result.first.id, equals(data.id));
      });
    });

    group('.updateAll()', () {
      test('update multiple items', () async {
        final data = await deposit.addAll([
          CarEntity(brand: 'VW', model: 'Nivus'),
          CarEntity(brand: 'VW', model: 'Virtus'),
        ]);

        await deposit.updateAll([
          data[0]
            ..brand = 'Toyota'
            ..model = 'Yaris',
          data[1]
            ..brand = 'Toyota'
            ..model = 'Ayigo',
        ]);

        final result = await deposit.by('brand', 'Toyota');

        expect(result.length, equals(2));
        expect(result[0].id, equals(data[0].id));
      });
    });
  });
}
