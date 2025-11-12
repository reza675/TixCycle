import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _database = FirebaseFirestore.instance;

  Future<void> setData({
    // simpan data
    required String path,
    required Map<String, dynamic> data,
  }) async {
    try {
      final reference = _database.doc(path);
      await reference.set(data);
    } catch (e) {
      print("Error setting data: $e");
      rethrow;
    }
  }

  Future<DocumentSnapshot> getDocument({required String path}) async {
    // ambil satu data/dokumen
    try {
      final reference = _database.doc(path);
      return await reference.get();
    } catch (e) {
      print("Error fetching document: $e");
      rethrow;
    }
  }

  Future<List<DocumentSnapshot>> getCollection({
    // ambil collection
    required String collectionPath,
  }) async {
    try {
      final reference = _database.collection(collectionPath);
      final snaphot = await reference.get();
      return snaphot.docs;
    } catch (e) {
      print("Error fetching collection: $e");
      rethrow;
    }
  }

  Future<QuerySnapshot> getQuery({
    required String collectionPath,
    required String whereField,
    required dynamic isEqualTo,
    String? orderBy, 
    bool descending = false, 
  }) async {
    try {
      Query query = _database
          .collection(collectionPath)
          .where(whereField, isEqualTo: isEqualTo);

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      return await query.get();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<QuerySnapshot> getPaginatedQuery({
    // data lazy loading
    required String collectionPath,
    required int limit,
    required String orderBy,
    bool descending = false,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query =
          _database.collection(collectionPath).orderBy(orderBy, descending: descending).limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      return await query.get();
    } catch (e) {
      print("Error in getPaginatedQuery: $e");
      rethrow;
    }
  }

  Future<void> updateData({
    // update data
    required String path,
    required Map<String, dynamic> data,
  }) async {
    try {
      final reference = _database.doc(path);
      await reference.update(data);
    } catch (e) {
      print("Error updating data: $e");
      rethrow;
    }
  }

  Future<void> decrementField({
    // kurangi nilai field (untuk stock tiket)
    required String path,
    required String field,
    required int decrementBy,
  }) async {
    try {
      final reference = _database.doc(path);
      await reference.update({
        field: FieldValue.increment(-decrementBy),
      });
    } catch (e) {
      print("Error decrementing field: $e");
      rethrow;
    }
  }

  Future<void> runTransaction({
    required Future<void> Function(Transaction) transactionHandler,
  }) async {
    try {
      await _database.runTransaction(transactionHandler);
    } catch (e) {
      print("Error running transaction: $e");
      rethrow;
    }
  }
}
