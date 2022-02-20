import 'package:deposit/deposit.dart';

/// A memory only implementation of [DepositAdapter].
class MemoryDepositAdapter extends DepositAdapter<int> {
  /// Construct a new [MemoryDepositAdapter].
  ///
  /// You can pass an optional [memory] to start with a certain database.
  MemoryDepositAdapter({
    Map<String, List<Map<String, dynamic>>>? memory,
  }) : _memory = memory ?? {};

  final Map<String, List<Map<String, dynamic>>> _memory;

  List<Map<String, dynamic>> _ref(String table) => _memory[table] ??= [];

  @override
  Future<Map<String, dynamic>> add(
    String table,
    String primaryColumn,
    Map<String, dynamic> data,
  ) async {
    final result = <String, dynamic>{
      primaryColumn: _ref(table).length + 1,
      ...data,
    };
    _ref(table).add(result);
    return result;
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
    final data = _ref(table).skip(skip).take(limit).toList();

    if (orderBy != null) {
      data.sort((a, b) {
        final dynamic valueA = (orderBy.ascending ? a : b)[orderBy.key];
        final dynamic valueB = (orderBy.ascending ? b : a)[orderBy.key];

        if (valueA is String && valueB is String) {
          return valueA.compareTo(valueB);
        } else if (valueA is num && valueB is num) {
          return valueA.compareTo(valueB);
        } else if (valueA is List && valueB is List) {
          return valueA.length < valueB.length ? 1 : -1;
        }
        return 0;
      });
    }
    return data;
  }

  @override
  Future<void> remove(
    String table,
    String primaryColumn,
    Map<String, dynamic> data,
  ) async {
    _ref(table).removeAt((data[primaryColumn] as int) - 1);
  }

  @override
  Future<Map<String, dynamic>> update(
    String table,
    String primaryColumn,
    Map<String, dynamic> data,
  ) async {
    return _ref(table)[(data[primaryColumn] as int) - 1] = data;
  }
}
