import 'package:firebase_auth/firebase_auth.dart';
import 'package:tixcycle/services/auth_service.dart';

class AuthRepository{
  final AuthService _authService;

  AuthRepository(this._authService);
  Stream<User?> get user => _authService.authStateChanges;
  User? get currentUser => _authService.getCurrentUser();

  Future<UserCredential> signIn(String email, String password){
    return _authService.signIn(email, password);;
  }

  Future<UserCredential> signUp(String email, String password){
    return _authService.signUp(email, password);
  }

  Future<void> signOut(){
    return _authService.signOut();
  }
}