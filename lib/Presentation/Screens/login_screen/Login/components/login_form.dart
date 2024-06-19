import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../../../Core/Firebase/Auth.dart';
import '../../../../../../Theme/const.dart';
import '../../../../../../Widgets/components/already_have_an_account_acheck.dart';
import '../../../../../../Widgets/components/constants.dart';
import '../../../Bottom_bar/admin_bottomBar.dart';
import '../../../Bottom_bar/user_bottombar.dart';
import '../../Signup/signup_screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() async {
    try {
      String email = _emailController.text;
      String password = _passwordController.text;

      if (_formKey.currentState!.validate()) {
        User? user = await _auth.signInWithEmailAndPassword(email, password);

        if (user != null) {
          Future.microtask(() {
            if (mounted) {
              route();
              print("User is successfully signed in");
            }
          });
        } else {
          _showErrorMessage("Email or Password Incorrect");
          print("Unexpected error: User is null");
        }
      }
    } catch (e) {
      print("Sign-in failed: $e");
      _showErrorMessage("Sign-in failed: $e");
    }
  }

  void route() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorMessage("No user logged in");
      return;
    }
    var documentSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (documentSnapshot.exists) {
      String userType = documentSnapshot.get('type');
      if (userType == "user") {
        _showSuccessSnackbar("Welcome to Grocery Master");
        Future.microtask(() {
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const UserBottom()),
                  (Route<dynamic> route) => false,
            );
          }
        });
      }
      else if (userType == "admin") {
        _showSuccessSnackbar("Welcome Admin");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AdminBottom()),
              (Route<dynamic> route) => false,
        );
      }
      else {
        _showErrorMessage("Some error in logging in!");
      }
    } else {
      _showErrorMessage("Some error in logging in!");
    }
  }

  void _showSuccessSnackbar(String message) {
    Future.microtask(() {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.notifications_active_outlined,
                color: Colors.green,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 6,
          margin: const EdgeInsets.all(20),
        ));
      }
    });
  }

  void _showErrorMessage(String message) {
    Future.microtask(() {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.white,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 6,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              cursorColor: kPrimaryColor,
              onSaved: (email) {},
              decoration: const InputDecoration(
                hintText: "Email",
                hintStyle: TextStyle(color: Colors.green),
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.person),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding),
              child: TextFormField(
                controller: _passwordController,
                textInputAction: TextInputAction.done,
                obscureText: !_isPasswordVisible,
                cursorColor: kPrimaryColor,
                decoration: InputDecoration(
                  hintText: "Password",
                  hintStyle: const TextStyle(color: Colors.green),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(defaultPadding),
                    child: Icon(Icons.lock),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: defaultPadding),
            SizedBox(
              width: 160,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  _signIn();
                },
                child: Text(
                  "Login".toUpperCase(),
                  style: TextStyle(color: kTextWhiteColor),
                ),
              ),
            ),
            const SizedBox(height: defaultPadding),
            AlreadyHaveAnAccountCheck(
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const SignUpScreen();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
