import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:deposit_supabase/deposit_supabase.dart';
import 'package:supabase/supabase.dart';

Future<HttpServer> supabaseServerMock({
  Map<String, List<Map<String, dynamic>>>? tables,
}) async {
  tables ??= {
    'todos': [
      <String, dynamic>{'id': 1, 'task': 'task 1', 'status': false},
      <String, dynamic>{'id': 2, 'task': 'task 2', 'status': true},
      <String, dynamic>{'id': 3, 'task': 'task 3', 'status': false},
      <String, dynamic>{'id': 4, 'task': 'task 4', 'status': true},
      <String, dynamic>{'id': 5, 'task': 'task 5', 'status': false},
      <String, dynamic>{'id': 6, 'task': 'task 6', 'status': true},
      <String, dynamic>{'id': 7, 'task': 'task 7', 'status': false},
    ],
  };

  final server = await HttpServer.bind('localhost', 0);
  unawaited(_handleRequests(server, tables));
  return server;
}

Future<void> _handleRequests(
  HttpServer server,
  Map<String, List<Map<String, dynamic>>> tables,
) async {
  await for (final request in server) {
    print(request.uri);
    final uri = request.uri;
    if (uri.pathSegments.first == 'rest') {
      switch (uri.pathSegments[1]) {
        case 'v1':
          await _handleRestV1(request, tables);
          break;
      }
    }
  }
}

Future<void> _handleRestV1(
  HttpRequest request,
  Map<String, List<Map<String, dynamic>>> tables,
) async {
  final response = request.response
    ..statusCode = HttpStatus.ok
    ..headers.contentType = ContentType.json;
  final query = request.uri.queryParameters;

  final tableName = request.uri.pathSegments.last;
  final table = tables[tableName];
  if (table == null) {
    // TODO: proper response.
    throw Exception('Table not found: $tableName');
  }

  final filters = {...query}
    ..remove('select')
    ..remove('limit');
  bool filter(Map<String, dynamic> data) {
    return filters.entries.every((entry) {
      final key = entry.key;
      final filter = entry.value.split('.').first;
      final value = entry.value.split('.').last;

      switch (filter) {
        case 'eq':
          dynamic v;
          if ((v = int.tryParse(value)) != null) {
            return data[key] == v;
          }
          return data[key] == value;
        default:
          throw Exception('Unknow filter option: $filter');
      }
    });
  }

  switch (request.method) {
    case 'GET':
      Map<String, dynamic> selector(Map<String, dynamic> data) {
        final select = (query['select'] ?? '*').split(',');
        if (select.first == '*') {
          return data;
        }
        return <String, dynamic>{
          for (final key in select) key: data[key],
        };
      }

      // Filter down and only select required.
      var data = table.map(selector).where(filter);

      // If single select
      if (request.headers.value(HttpHeaders.acceptHeader) ==
          'application/vnd.pgrst.object+json') {
        response.write(json.encode(data.first));
      } else {
        // If there are limits.
        final limit = int.tryParse(query['limit'] ?? '');
        if (limit != null) {
          data = data.take(limit);
        }

        response.headers.set('content-range', data.length);
        response.write(json.encode(data.toList()));
      }

      break;
    case 'POST':
      final body = await request
          .cast<List<int>>()
          .transform<String>(utf8.decoder)
          .join();
      final dynamic jsonData = json.decode(body);
      final List<Map<String, dynamic>> data;
      if (jsonData is Map<String, dynamic>) {
        data = [jsonData];
      } else {
        data = (json.decode(body) as List).cast<Map<String, dynamic>>();
      }
      table.addAll(data);

      response.write(body);
      break;
    case 'PATCH':
      final body = await request
          .cast<List<int>>()
          .transform<String>(utf8.decoder)
          .join();
      final dynamic jsonData = json.decode(body);
      final List<Map<String, dynamic>> data;
      if (jsonData is Map<String, dynamic>) {
        data = [jsonData];
      } else {
        data = (json.decode(body) as List).cast<Map<String, dynamic>>();
      }

      final updated = table.where(filter).toList();
      for (final update in data) {
        for (final item in updated) {
          item.addAll(<String, dynamic>{
            for (final entry in update.entries) entry.key: entry.value,
          });
        }
      }

      response.write(json.encode(updated));

      break;
    case 'DELETE':
      final removed = table.where(filter).toList();
      removed.forEach(table.remove);

      response.write(json.encode(removed));
      break;
    default:
      throw Exception('Unknown method ${request.method} on ${request.uri}');
  }
  await response.close();
}

Future<void> main() async {
  final server = await supabaseServerMock(
    tables: {
      'cars': [],
    },
  );
  final client = SupabaseClient(
    'http://${server.address.host}:${server.port}',
    'supabaseKey',
  );
  final adapter = SupabaseDepositAdapter(client);

  await adapter.add(
    'cars',
    'id',
    <String, dynamic>{'brand': 'VW', 'model': 'Nivus'},
  );
  final result = await client.from('cars').select().execute();
  final data = result.data as List;
  print(data);
}
