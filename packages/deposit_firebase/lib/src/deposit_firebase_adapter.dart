import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deposit/deposit.dart';

extension _QueryDocumentSnapshotX on DocumentSnapshot {
  Map<String, dynamic> toMap() {
    final _data = (data() ?? {}) as Map<String, dynamic>;

    return <String, dynamic>{
      'id': id,
      ..._data,
    };
  }
}

class FirebaseDepositAdapter extends DepositAdapter<String> {
  FirebaseDepositAdapter({required this.firestore});

  final FirebaseFirestore firestore;

  @override
  Future<Map<String, dynamic>> add(
    String table,
    String primaryColumn,
    Map<String, dynamic> data,
  ) async {
    final value = await firestore.collection(table).add(data);

    final snapshot = await value.snapshots().first;
    final returnedData = snapshot.data();

    if (returnedData == null) {
      throw Exception('Unable to insert data into "$table"');
    } else {
      return snapshot.toMap();
    }
  }

  @override
  Future<List<Map<String, dynamic>>> by(String table, String key, value) async {
    final data = await firestore
        .collection(table)
        .where(
          key,
          isEqualTo: value,
        )
        .get();

    return data.docs.map((doc) => doc.toMap()).toList();
  }

  @override
  Future<bool> exists(String table, String primaryColumn, String id) async {
    if (primaryColumn == 'id') {
      final doc = await firestore.collection(table).doc(id);
      final snap = await doc.get();
      return snap.exists;
    } else {
      final data = await firestore
          .collection(table)
          .where(primaryColumn, isEqualTo: id)
          .get();

      return data.docs.isNotEmpty;
    }
  }

  @override
  Future<Map<String, dynamic>> getById(
    String table,
    String primaryColumn,
    String id,
  ) async {
    if (primaryColumn != 'id') {
      throw ArgumentError(
        'Firebase can only get documents by id using the "id" field',
      );
    }
    final doc = await firestore.collection(table).doc(id);
    final snap = await doc.get();
    return snap.toMap();
  }

  @override
  Future<List<Map<String, dynamic>>> page(
    String table, {
    required int limit,
    required int skip,
    OrderBy? orderBy,
  }) async {
    throw UnsupportedError(
      "Firebase adapter can't paginate with numeric offset",
    );
  }

  @override
  Future<void> remove(
    String table,
    String primaryColumn,
    Map<String, dynamic> data,
  ) async {
    final doc = await firestore.collection(table).doc(data[primaryColumn]);

    await doc.delete();
  }

  @override
  Future<Map<String, dynamic>> update(
    String table,
    String primaryColumn,
    Map<String, dynamic> data,
  ) async {
    final doc = await firestore.collection(table).doc(data[primaryColumn]);

    await doc.update(data);

    return data;
  }
}
