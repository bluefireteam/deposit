import 'package:deposit/deposit.dart';

/// A memory only implementation of [DepositAdapter].
class MemoryDepositAdapter extends DepositAdapter<int> {
  final Map<String, List<Map<String, dynamic>>> _memory = {};

  List<Map<String, dynamic>> _ref(String table) => _memory[table] ??= [];

  @override
  Future<Map<String, dynamic>> add(
    String table,
    Map<String, dynamic> data,
  ) async {
    _ref(table).add(data);
    return data;
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
    return _ref(table).where((item) => item['id'] == id).length == 1;
  }

  @override
  Future<Map<String, dynamic>> getById(
    String table,
    String primaryColumn,
    int id,
  ) async {
    return _ref(table).firstWhere((item) => item['id'] == id);
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
    _ref(table).removeWhere((item) {
      return item[primaryColumn] == data[primaryColumn];
    });
  }

  @override
  Future<Map<String, dynamic>> update(
    String table,
    String primaryColumn,
    Map<String, dynamic> data,
  ) async {
    final index = _ref(table).indexWhere(
      (item) => item[primaryColumn] == data[primaryColumn],
    );
    return _ref(table)[index] = data;
  }
}
