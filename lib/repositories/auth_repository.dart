import 'package:firebase_auth/firebase_auth.dart';
import 'package:tixcycle/models/user_model.dart';
import 'package:tixcycle/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixcycle/repositories/user_repository.dart';

class AuthRepository{
  final AuthService _authService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserRepository _userRepository;

  AuthRepository(this._authService, this._userRepository);
  Stream<User?> get user => _authService.authStateChanges;
  User? get currentUser => _authService.getCurrentUser();

  Future<UserCredential> signIn(String email, String password){
    return _authService.signIn(email, password);
  }

  Future<void> signUp({
    required String username,
    required String password,
    required String displayName,
    required String email,
  }) async {
    try {
      
    UserCredential userCredential = await _authService.signUp(email,  password);
    User? newUser = userCredential.user;
    
    if (newUser != null){
      UserModel userProfile = UserModel(id: newUser.uid, username: username, email: email, displayName: displayName, timeCreated: Timestamp.now());
      
      await _userRepository.buatProfilUser(userProfile);
    } else {
      throw Exception('User registration failed');
    }
    } catch (e) {
      rethrow;
    }
    
  }

  Future<void> signOut(){
    return _authService.signOut();
  }
}