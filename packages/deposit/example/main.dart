import 'dart:developer';

import 'package:deposit/deposit.dart';

class ExampleAdapter extends DepositAdapter<int> {
  @override
  Future<Map<String, dynamic>> add(
    String table,
    Map<String, dynamic> data,
  ) async {
    return data;
  }

  @override
  Future<List<Map<String, dynamic>>> page(
    String table, {
    required int limit,
    required int skip,
    OrderBy? orderBy,
  }) async {
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> by(
    String table,
    String key,
    dynamic value,
  ) async {
    return [];
  }

  @override
  Future<bool> exists(String table, String primaryColumn, int id) async {
    return id.isEven;
  }

  @override
  Future<Map<String, dynamic>> getById(
    String table,
    String primaryColumn,
    int id,
  ) async {
    return <String, dynamic>{
      'id': id,
    };
  }

  @override
  Future<void> remove(
    String table,
    String primaryColumn,
    Map<String, dynamic> data,
  ) async {}

  @override
  Future<Map<String, dynamic>> update(
    String table,
    String primaryColumn,
    Map<String, dynamic> data,
  ) async {
    return data;
  }
}

class MovieEntity extends Entity {
  MovieEntity({
    this.id,
    required this.title,
  });

  factory MovieEntity.fromJSON(Map<String, dynamic> data) {
    return MovieEntity(
      id: data['id'] as int?,
      title: data['title'] as String? ?? 'No title',
    );
  }

  int? id;

  String title;

  @override
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'id': id,
      'title': title,
    };
  }
}

class MovieDeposit extends Deposit<MovieEntity, int> {
  MovieDeposit() : super('movies', MovieEntity.fromJSON);
}

Future<void> main() async {
  Deposit.defaultAdapter = ExampleAdapter();

  final movieDeposit = MovieDeposit();

  final movie = await movieDeposit.getById(1);
  log('Movie id: ${movie.id}');

  await movieDeposit.page(orderBy: OrderBy('title'));
}
