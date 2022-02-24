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

class FirestoreDepositAdapter extends DepositAdapter<String> {
  FirestoreDepositAdapter({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<Map<String, dynamic>> add(
    String table,
    String primaryColumn,
    Map<String, dynamic> data,
  ) async {
    final value = await _firestore.collection(table).add(data);

    final snapshot = await value.snapshots().first;
    final returnedData = snapshot.data();

    if (returnedData == null) {
      throw Exception('Unable to insert data into "$table"');
    } else {
      return snapshot.toMap();
    }
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
  Future<List<Map<String, dynamic>>> by(String table, String key, value) async {
    final data = await _firestore
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
    final snap = await _getDoc(primaryColumn, table, id);
    return snap?.exists ?? false;
  }

  @override
  Future<Map<String, dynamic>> getById(
    String table,
    String primaryColumn,
    String id,
  ) async {
    final snap = await _getDoc(primaryColumn, table, id);

    if (snap == null) {
      /// Probably better to change this method signature to allow null
      throw Exception('Unable to find doc');
    }

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
      "Firestore adapter can't paginate with numeric offset",
    );
  }

  @override
  Future<void> remove(
    String table,
    String primaryColumn,
    Map<String, dynamic> data,
  ) async {
    // TODO: Check if the id is not null and throw exception in case it is
    final doc = await _getDocRef(primaryColumn, table, data[primaryColumn]);
    await doc?.delete();
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
    // TODO: Check if the id is not null and throw exception in case it is
    final doc = await _getDocRef(primaryColumn, table, data[primaryColumn]);
    await doc?.update(data);

    return data;
  }

  @override
  Future<List<Map<String, dynamic>>> updateAll(
    String table,
    String primaryColumn,
    List<Map<String, dynamic>> data,
  ) {
    return Future.wait(data.map((d) => update(table, primaryColumn, d)));
  }

  Future<DocumentReference?> _getDocRef(
    String primaryColumn,
    String table,
    String id,
  ) async {
    final snap = await _getDoc(primaryColumn, table, id);

    if (snap != null) {
      final doc = _firestore.collection(table).doc(snap.id);
      return doc;
    }

    return null;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> _getDoc(
    String primaryColumn,
    String table,
    String id,
  ) async {
    if (primaryColumn == 'id') {
      final doc = await _firestore.collection(table).doc(id);
      return await doc.get();
    } else {
      final data = await _firestore
          .collection(table)
          .where(primaryColumn, isEqualTo: id)
          .get();

      if (data.docs.isEmpty) {
        return null;
      }

      return data.docs.first;
    }
  }
}
