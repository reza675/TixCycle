import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? getCurrentUser(){   // fetch data user yang login
    return _firebaseAuth.currentUser;
  }

  Future<UserCredential> signUp(String email, String password) async {      // buat akun baru
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

    }on FirebaseAuthException catch(e) {
      print("Firebase Authentication Exception: ${e.message}");
      rethrow;
    } catch (e) {
      print("An unexpected error accurred: $e");
      rethrow;
    }
  }

  Future<UserCredential> signIn(String email, String password) async {      // sign in
    try{
      return await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

    } on FirebaseAuthException catch (e) {
      print("Firebase Authentication Exception: ${e.message}");
      rethrow;
    } catch (e) {
      print("An unexpected error accurred: $e");
      rethrow;
    }
  }

  Future<void> signOut()async {     // sign out
    await _firebaseAuth.signOut();
  }
}