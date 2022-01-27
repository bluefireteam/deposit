import 'package:deposit/deposit.dart';

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
  Future<bool> exists(String table, int id) async {
    return _ref(table).where((item) => item['id'] == id).length == 1;
  }

  @override
  Future<Map<String, dynamic>> getById(String table, int id) async {
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
        final dynamic valueA = (orderBy.ascending ? b : a)[orderBy.key];
        final dynamic valueB = (orderBy.ascending ? a : b)[orderBy.key];

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
  Future<void> remove(String table, Map<String, dynamic> data) async {
    _ref(table).removeWhere((item) {
      return data.keys.every((key) => item[key] == data[key]);
    });
  }

  @override
  Future<Map<String, dynamic>> update(String table, Map<String, dynamic> data) {
    final index = _ref(table).firstWhere((element) => )
  }
}
