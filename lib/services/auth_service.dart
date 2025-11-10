import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  
  bool _isGoogleSignInInitialized = false;

  Future<void> _initializeGoogleSignIn() async {
    if (_isGoogleSignInInitialized) return; 

    try {
      await _googleSignIn.initialize(
        serverClientId: '868459385765-lvtd9hobafcqcnmbb3p1mcarlhi2edca.apps.googleusercontent.com',
      );
      _isGoogleSignInInitialized = true;
    } catch (e) {
      print("Gagal inisialisasi Google Sign-In: $e");
      rethrow;
    }
  }
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  Future<UserCredential> signUp(String email, String password) async {
    // buat akun baru
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      print("Firebase Authentication Exception: ${e.message}");
      rethrow;
    } catch (e) {
      print("An unexpected error accurred: $e");
      rethrow;
    }
  }

  Future<UserCredential> signIn(String email, String password) async {
    // sign in
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      print("Firebase Authentication Exception: ${e.message}");
      rethrow;
    } catch (e) {
      print("An unexpected error accurred: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _initializeGoogleSignIn(); 
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      await _initializeGoogleSignIn();

      final GoogleSignInAccount? googleUser =
          await _googleSignIn.authenticate(); 

      if (googleUser == null) {
        throw FirebaseAuthException(code: 'sign-in-cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      print("Error signInWithGoogle: $e");
      rethrow;
    }
  }
}