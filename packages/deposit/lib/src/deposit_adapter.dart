import 'package:deposit/deposit.dart';

/// A [DepositAdapter] serves as a data backend for [Deposit] classes.
///
/// It is designed to be generic enough that it can be used against any given
/// data backend.
abstract class DepositAdapter<Id> {
  /// Construct a new adapter.
  const DepositAdapter();

  /// Check if given [id] exists in the [table].
  Future<bool> exists(String table, String primaryColumn, Id id);

  /// Return list of paginated data.
  Future<List<Map<String, dynamic>>> page(
    String table, {
    required int limit,
    required int skip,
    OrderBy? orderBy,
  });

  /// Return data that is referenced by the given [Id] in the [table].
  Future<Map<String, dynamic>> getById(
    String table,
    String primaryColumn,
    Id id,
  );

  /// Return data that is referenced by the given [key] and the [value].
  Future<List<Map<String, dynamic>>> by(
    String table,
    String key,
    dynamic value,
  );

  /// Store data in the backend and return the newly stored data.
  Future<Map<String, dynamic>> add(
    String table,
    String primaryColumn,
    Map<String, dynamic> data,
  );

  /// Store multiple items in the backend and return the newly stored data.
  Future<List<Map<String, dynamic>>> addAll(
    String table,
    String primaryColumn,
    List<Map<String, dynamic>> data,
  );

  /// Update data in the backend and return the newly updated data.
  Future<Map<String, dynamic>> update(
    String table,
    String primaryColumn,
    Map<String, dynamic> data,
  );

  /// Update multiple items in the backend and return the newly updated data.
  Future<List<Map<String, dynamic>>> updateAll(
    String table,
    String primaryColumn,
    List<Map<String, dynamic>> data,
  );

  /// Remove data in the backend.
  Future<void> remove(
    String table,
    String primaryColumn,
    Map<String, dynamic> data,
  );

  /// Remove multiple items in the backend.
  Future<void> removeAll(
    String table,
    String primaryColumn,
    List<Map<String, dynamic>> data,
  );

  // TODO(wolfen): search?

  // TODO(wolfen): upsert?
}
