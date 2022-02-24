import 'package:deposit/deposit.dart';

/// A [Deposit] serves as a storage of entities with generic methods for
/// managing entities.
///
/// It is designed to be subclassed so end-users can add their own
/// business-specific methods to it.
class Deposit<E extends Entity, Id> {
  /// Construct a new [Deposit] that will retrieve it's entities from [table].
  ///
  /// If [adapter] is not given it will use the [defaultAdapter] as the data
  /// backend.
  Deposit(
    this.table,
    this.builder, {
    DepositAdapter<Id>? adapter,
    this.primaryColumn = 'id',
  }) : _adapter = adapter ?? defaultAdapter as DepositAdapter<Id>;

  /// The default adapter for any [Deposit] to use when no adapter is given in
  /// the constructor.
  static late final DepositAdapter defaultAdapter;

  /// Reference to the internal data store for the [_adapter].
  final String table;

  /// The primary column of the [Entity].
  final String primaryColumn;

  /// Entity builder.
  final E Function(Map<String, dynamic>) builder;

  final DepositAdapter<Id> _adapter;

  /// Check if an [Entity] exists with the given [Id].
  Future<bool> exists(Id id) => _adapter.exists(table, primaryColumn, id);

  /// Return a list of paginated entities.
  Future<List<E>> page({
    int limit = 50,
    int skip = 0,
    OrderBy? orderBy,
  }) async {
    return (await _adapter.page(
      table,
      limit: limit,
      skip: skip,
      orderBy: orderBy,
    ))
        .map(builder)
        .toList();
  }

  /// Retrieve an [Entity] by [Id].
  Future<E> getById(Id id) async {
    return builder(await _adapter.getById(table, primaryColumn, id));
  }

  /// Retrieve an [Entity] by given [key] matching the [value].
  Future<List<E>> by(String key, dynamic value) async {
    return (await _adapter.by(table, key, value)).map(builder).toList();
  }

  /// Add an [Entity] in the data backend and return the newly stored [Entity].
  Future<E> add(E entity) async {
    return builder(await _adapter.add(table, primaryColumn, entity.toJSON()));
  }

  /// Add a list of entities in the data backend and return the newly stored
  /// entities.
  Future<List<E>> addAll(List<E> entities) async {
    final result = await _adapter.addAll(
      table,
      primaryColumn,
      entities.map((e) => e.toJSON()).toList(),
    );
    return result.map(builder).toList();
  }

  /// Update an [Entity] in the data backend and return the newly updated
  /// [Entity].
  Future<E> update(E entity) async {
    return builder(
      await _adapter.update(table, primaryColumn, entity.toJSON()),
    );
  }

  /// Update a list of entities in the data backend and return the newly updated
  /// entities.
  Future<List<E>> updateAll(List<E> entities) async {
    final result = await _adapter.updateAll(
      table,
      primaryColumn,
      entities.map((e) => e.toJSON()).toList(),
    );
    return result.map(builder).toList();
  }

  /// Remove an [Entity] in the data backend.
  Future<void> remove(E entity) => _adapter.remove(
        table,
        primaryColumn,
        entity.toJSON(),
      );

  /// Remove a list of entities in the data backend.
  Future<void> removeAll(List<E> entities) async {
    await _adapter.removeAll(
      table,
      primaryColumn,
      entities.map((e) => e.toJSON()).toList(),
    );
  }
  // TODO(wolfen): search?

  // TODO(wolfen): upsert?
}
