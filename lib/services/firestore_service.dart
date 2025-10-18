import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _database = FirebaseFirestore.instance;

  Future<void> simpanData({
    required String path, required Map<String,dynamic> data,
  }) async {
    try{
      final reference = _database.doc(path);
      await reference.set(data);
    } catch(e) {
      print(e);
      rethrow;
    }
  }

  Future<DocumentSnapshot> ambilSatuDdata({required String path}) async {
    try{
      final reference = _database.doc(path);
      return await reference.get();
    }catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<List<DocumentSnapshot>> ambilCollection({
    required String collectionPath,
  }) async {
    try {
      final reference = _database.collection(collectionPath);
      final snaphot = await reference.get();
      return snaphot.docs;
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}