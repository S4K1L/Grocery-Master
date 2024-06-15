import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocerymaster/Presentation/Screens/login_screen/Login/login_screen.dart';
import '../../../../../../Core/Firebase/Auth.dart';
import '../../../../../../Theme/const.dart';
import '../../../../../../Widgets/components/constants.dart';
import '../../Bottom_bar/admin_bottomBar.dart';

class AdminLoginForm extends StatefulWidget {
  const AdminLoginForm({
    Key? key,
  }) : super(key: key);

  @override
  State<AdminLoginForm> createState() => _AdminLoginFormState();
}

class _AdminLoginFormState extends State<AdminLoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
          route();
          print("User is successfully signed in");
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
      if (userType == "admin") {
        _showSuccessSnackbar("Welcome Admin");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AdminBottom()),
              (Route<dynamic> route) => false,
        );
      } else {
        _showErrorMessage("Some error in logging in!");
      }
    } else {
      _showErrorMessage("Some error in logging in!");
    }
  }


  void _showSuccessSnackbar(String message) {
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

  void _showErrorMessage(String message) {
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
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding),
              child: TextFormField(
                controller: _passwordController,
                textInputAction: TextInputAction.done,
                obscureText: true,
                cursorColor: kPrimaryColor,
                decoration: const InputDecoration(
                  hintText: "Password",
                  hintStyle: TextStyle(color: Colors.green),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(defaultPadding),
                    child: Icon(Icons.lock),
                  ),
                ),
              ),
            ),
            const SizedBox(height: defaultPadding),
            Container(
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: TextButton(onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return LoginScreen();
                    },
                  ),
                );
              }, child: Row(
                children: [
                  Text('User? ',style: TextStyle(color: Colors.green),),
                  Text('Log in here!',style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green
                  ),),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }
}
