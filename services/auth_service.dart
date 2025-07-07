import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:developer';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  User? get currentUser => _auth.currentUser;
  
  Future<UserCredential> signIn(String email, String password) async {
    try {
      // Menggunakan try-catch khusus untuk menangani error Pigeon
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      // Log error dan rethrow
      log('Error during sign in: $e');
      rethrow;
    }
  }
  
  Future<UserCredential> signUp(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      log('Error during sign up: $e');
      rethrow;
    }
  }
  
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log('Error during sign out: $e');
      rethrow;
    }
  }
  
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      log('Error during password reset: $e');
      rethrow;
    }
  }
  
  // Workaround untuk masalah PigeonUserDetails
  Future<bool> isUserLoggedIn() async {
    try {
      final user = _auth.currentUser;
      return user != null;
    } catch (e) {
      log('Error checking login status: $e');
      return false;
    }
  }
}