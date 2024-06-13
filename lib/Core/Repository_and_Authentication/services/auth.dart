import 'package:firebase_auth/firebase_auth.dart';
import '../data/custom_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
  Future<CustomUser?> registerStudent(String email, String password) async {
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
  Future<CustomUser?> loginStudent(String email, String password) async {
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

// Logout function
  Future<void> logout() async {
    try {
      if (_auth.currentUser != null) {
        await _auth.signOut();
      } else {
        print("No user is currently signed in");
      }
    } catch (e) {
      print("Error logging out: $e");
      throw e; // Throw the error to handle it in the UI
    }
  }


}
