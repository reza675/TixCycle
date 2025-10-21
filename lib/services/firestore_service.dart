import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _database = FirebaseFirestore.instance;

  Future<void> setData({    // simpan data
    required String path, required Map<String,dynamic> data,
  }) async {
    try{
      final reference = _database.doc(path);
      await reference.set(data);
    } catch(e) {
      print("Error setting data: $e");
      rethrow;
    }
  }

  Future<DocumentSnapshot> getDocument({required String path}) async {    // ambil satu data/dokumen
    try{
      final reference = _database.doc(path);
      return await reference.get();
    }catch (e) {
      print("Error fetching document: $e");
      rethrow;
    }
  }

  Future<List<DocumentSnapshot>> getCollection({    // ambil collection
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

  Future<QuerySnapshot> getQuery({    // filter data berdasarkan kondisi 
    required String collectionPath,
    required String whereField,
    required dynamic isEqualTo,
  }) async {
    try {
      final reference = _database.collection(collectionPath);
      return await reference.where(whereField,isEqualTo: isEqualTo).get();
    } catch(e){
      print("Error getting query: $e");
      rethrow;
    }
  }

  Future<QuerySnapshot> getPaginatedQuery({   // data lazy loading
    required String collectionPath,
    required int limit,
    required String orderBy,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _database.collection(collectionPath).orderBy(orderBy).limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      return await query.get();
    } catch (e) {
      print("Error in getPaginatedQuery: $e");
      rethrow;
    }
  }
}