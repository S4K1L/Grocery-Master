import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Repository_and_Authentication/data/custom_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Converts Firebase user to Custom User
  CustomUser? _convertUser(User? user) {
    if (user == null) {
      return null;
    } else {
      return CustomUser(uid: user.uid, email: user.email);
    }
  }

  // Setting up stream
  // This continuously listens to auth changes (that is login or log out)
  // This will return the user if logged in or return null if not
  Stream<CustomUser?> get streamUser {
    return _auth.authStateChanges().map((User? user) => _convertUser(user));
  }

  // Register part with email and password
  Future<CustomUser?> registerUser(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return _convertUser(user);
    } catch (e) {
      print("Error in registering: $e");
      return null;
    }
  }

  // Login part with email and password
  Future<CustomUser?> loginUser(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return _convertUser(user);
    } catch (e) {
      print("Error in login: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>> getUserData(String uid) async {
    try {
      DocumentSnapshot userData = await _firestore.collection('users').doc(uid).get();
      return userData.data() as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching user data: $e');
      return {};
    }
  }

}