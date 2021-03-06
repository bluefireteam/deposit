import 'package:deposit/deposit.dart';

/// A memory only implementation of [DepositAdapter].
class MemoryDepositAdapter extends DepositAdapter<int> {
  /// Construct a new [MemoryDepositAdapter].
  ///
  /// You can pass an optional [memory] to start with a certain database.
  MemoryDepositAdapter({
    Map<String, List<Map<String, dynamic>>>? memory,
  }) : _memory = memory ?? {} {
    _idCounters = {
      for (final key in _memory.keys) key: _memory[key]!.length,
    };
  }

  final Map<String, List<Map<String, dynamic>>> _memory;

  late final Map<String, int> _idCounters;

  List<Map<String, dynamic>> _ref(String table) => _memory[table] ??= [];

  int _count(String table) =>
      _idCounters[table] = (_idCounters[table] ?? 0) + 1;

  @override
  Future<Map<String, dynamic>> add(
    String table,
    String primaryColumn,
    Map<String, dynamic> data,
  ) async {
    final result = <String, dynamic>{
      ...data,
      primaryColumn: _count(table),
    };
    _ref(table).add(result);
    return result;
  }

  @override
  Future<List<Map<String, dynamic>>> addAll(
    String table,
    String primaryColumn,
    List<Map<String, dynamic>> data,
  ) {
    return Future.wait(data.map((d) => add(table, primaryColumn, d)));
  }

  @override
  Future<List<Map<String, dynamic>>> by(
    String table,
    String key,
    dynamic value,
  ) async {
    return _ref(table).where((item) => item[key] == value).toList();
  }

  @override
  Future<bool> exists(String table, String primaryColumn, int id) async {
    return _ref(table).where((item) => item[primaryColumn] == id).length == 1;
  }

  @override
  Future<Map<String, dynamic>> getById(
    String table,
    String primaryColumn,
    int id,
  ) async {
    return _ref(table).firstWhere((item) => item[primaryColumn] == id);
  }

  @override
  Future<List<Map<String, dynamic>>> page(
    String table, {
    required int limit,
    required int skip,
    OrderBy? orderBy,
  }) async {
    final data = [..._ref(table)];

    if (orderBy != null) {
      data.sort((d1, d2) {
        final dynamic value1 = d1[orderBy.key];
        final dynamic value2 = d2[orderBy.key];

        if (orderBy.ascending) {
          if (value1 is Comparable) {
            return value1.compareTo(value2);
          }
        } else {
          if (value2 is Comparable) {
            return value2.compareTo(value1);
          }
        }

        return 0;
      });
    }
    return data.skip(skip).take(limit).toList();
  }

  @override
  Future<void> remove(
    String table,
    String primaryColumn,
    Map<String, dynamic> data,
  ) async {
    _ref(table).removeWhere(
      (d) => d[primaryColumn] == data[primaryColumn],
    );
  }

  @override
  Future<void> removeAll(
    String table,
    String primaryColumn,
    List<Map<String, dynamic>> data,
  ) async {
    await Future.wait(data.map((d) => remove(table, primaryColumn, d)));
  }

  @override
  Future<Map<String, dynamic>> update(
    String table,
    String primaryColumn,
    Map<String, dynamic> data,
  ) async {
    final result = await getById(
      table,
      primaryColumn,
      data[primaryColumn] as int,
    );
    return result..addAll(data);
  }

  @override
  Future<List<Map<String, dynamic>>> updateAll(
    String table,
    String primaryColumn,
    List<Map<String, dynamic>> data,
  ) {
    return Future.wait(data.map((d) => update(table, primaryColumn, d)));
  }
}
