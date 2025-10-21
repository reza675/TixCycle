import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixcycle/models/user_model.dart';
import 'package:tixcycle/services/firestore_service.dart';

class UserRepository {
  final FirestoreService _firestoreService;
  final String _collectionPath = 'users';
  UserRepository(this._firestoreService);

  Future<void> buatProfilUser(UserModel user)async {
    await _firestoreService.setData(path: '$_collectionPath/${user.id}', data: user.toJson());
  }

  Future<UserModel> ambilProfilUser(String userId) async{
    try{
      DocumentSnapshot doc = await _firestoreService.getDocument(path:  '$_collectionPath/$userId');
      if(doc.exists){
        return UserModel.fromSnapshot(doc);
      } else {
        throw Exception("User profile not found");
      }
    } catch (e){
      print(e);
      rethrow;
    }
  }
}