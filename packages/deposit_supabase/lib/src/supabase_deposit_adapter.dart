import 'package:deposit/deposit.dart';
import 'package:supabase/supabase.dart';

/// A Supabase backed implementation of [DepositAdapter].
class SupabaseDepositAdapter extends DepositAdapter<int> {
  const SupabaseDepositAdapter(this._client);

  final SupabaseClient _client;

  SupabaseQueryBuilder _from(String table) => _client.from(table);

  @override
  Future<Map<String, dynamic>> add(
    String table,
    String primaryColumn,
    Map<String, dynamic> data,
  ) async {
    return (await addAll(table, primaryColumn, [data])).first;
  }

  @override
  Future<List<Map<String, dynamic>>> addAll(
    String table,
    String primaryColumn,
    List<Map<String, dynamic>> data,
  ) async {
    final response = await _from(table).insert(data).execute();
    if (response.error != null) {
      throw response.error!;
    }
    return (response.data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  @override
  Future<List<Map<String, dynamic>>> by(
    String table,
    String key,
    dynamic value,
  ) async {
    final response = await _from(table).select().eq(key, value).execute();
    if (response.error != null) {
      throw response.error!;
    }
    return (response.data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  @override
  Future<bool> exists(String table, String primaryColumn, int id) async {
    final response =
        await _from(table).select().eq(primaryColumn, id).limit(1).execute();
    return response.count == 1;
  }

  @override
  Future<Map<String, dynamic>> getById(
    String table,
    String primaryColumn,
    int id,
  ) async {
    final response =
        await _from(table).select().eq(primaryColumn, id).single().execute();
    if (response.error != null) {
      throw response.error!;
    }
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> page(
    String table, {
    required int limit,
    required int skip,
    OrderBy? orderBy,
  }) async {
    final query = _from(table).select().range(skip, limit);
    if (orderBy != null) {
      query.order(orderBy.key, ascending: orderBy.ascending);
    }

    final response = await query.execute();
    if (response.error != null) {
      throw response.error!;
    }
    return (response.data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  @override
  Future<void> remove(
    String table,
    String primaryColumn,
    Map<String, dynamic> data,
  ) async {
    final response = await _from(table).delete().match(<String, dynamic>{
      primaryColumn: data[primaryColumn],
    }).execute();

    if (response.error != null) {
      throw response.error!;
    }
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
    final response = await _from(table).update(data).match(<String, dynamic>{
      primaryColumn: data[primaryColumn],
    }).execute();

    if (response.error != null) {
      throw response.error!;
    }
    return (response.data as List<dynamic>).cast<Map<String, dynamic>>().first;
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
