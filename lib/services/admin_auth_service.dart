import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hardcoded admin credentials for demo/university project
  // NOTE: This is NOT secure and should NOT be used in production
  static const String _adminUsername = 'admin';
  static const String _adminPassword = 'admin123';
  static const String _adminEmail = 'admin@gmail.com';

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Check if using hardcoded admin credentials
      if (email == _adminUsername && password == _adminPassword) {
        // Try to sign in with Firebase using admin email
        try {
          await _auth.signInWithEmailAndPassword(
            email: _adminEmail,
            password: _adminPassword,
          );
          return true;
        } catch (e) {
          print('Admin Firebase auth failed: $e');
          // If Firebase auth fails, still allow login (for demo)
          return true;
        }
      }

      // For regular admin login with email
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if user has admin role in Firestore
      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      if (userDoc.exists && userDoc.data()?['role'] == 'admin') {
        return true;
      }

      // Not an admin
      await _auth.signOut();
      return false;
    } catch (e) {
      print('Admin sign in error: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check if current user is admin
  Future<bool> isAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      return userDoc.exists && userDoc.data()?['role'] == 'admin';
    } catch (e) {
      return false;
    }
  }
}
