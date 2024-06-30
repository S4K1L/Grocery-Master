import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../../../Core/Firebase/Auth.dart';
import '../../../../../../Theme/const.dart';
import '../../../../../../Widgets/components/already_have_an_account_acheck.dart';
import '../../../../../Widgets/components/constants.dart';
import '../../../Bottom_bar/user_bottombar.dart';
import '../../Login/login_screen.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  void _uploadData(String qrCodeUrl) {
    UserDataUploader.uploadUserData(
      name: _nameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      password: _passwordController.text,
      address: _addressController.text,
      qrCodeUrl: qrCodeUrl,
    );
  }

  Future<String> _generateQRCodeAndUpload() async {
    // Collect user data
    final userData = {
      "name": _nameController.text,
      "phone": _phoneController.text,
      "email": _emailController.text,
      "address": _addressController.text,
    };
    final userDataString = userData.entries.map((e) => '${e.key}: ${e.value}').join('\n');

    final tempDir = await getTemporaryDirectory();
    final qrCodeFile = File('${tempDir.path}/qr_code.png');
    final qrValidationPainter = QrPainter(
      data: userDataString,
      version: QrVersions.auto,
      gapless: true,
    );

    final picData = await qrValidationPainter.toImageData(200);
    await qrCodeFile.writeAsBytes(picData!.buffer.asUint8List());

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('qr_codes/${DateTime.now().millisecondsSinceEpoch}.png');

    final uploadTask = storageRef.putFile(qrCodeFile);
    final snapshot = await uploadTask;
    final qrCodeUrl = await snapshot.ref.getDownloadURL();

    return qrCodeUrl;
  }

  void _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      String email = _emailController.text;
      String password = _passwordController.text;

      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        final qrCodeUrl = await _generateQRCodeAndUpload();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.notifications_active_outlined, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Welcome Grocery Master",
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.white,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 6,
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const UserBottom(),
          ),
        );

        _uploadData(qrCodeUrl);
        print("Data uploaded successfully");
        print("User successfully created");
      } else {
        _showErrorMessage("Some error found!");
      }
    } catch (e) {
      _showErrorMessage("Sign-up failed: $e");
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 6,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            decoration: const InputDecoration(
              hintText: "Name",
              hintStyle: TextStyle(color: Colors.green),
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.drive_file_rename_outline),
              ),
            ),
          ),
          SizedBox(height: defaultPadding),
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
                child: Icon(Icons.email_outlined),
              ),
            ),
          ),
          SizedBox(height: defaultPadding),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            onSaved: (email) {},
            decoration: const InputDecoration(
              hintText: "Phone",
              hintStyle: TextStyle(color: Colors.green),
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.phone),
              ),
            ),
          ),
          SizedBox(height: defaultPadding),
          TextFormField(
            controller: _addressController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            onSaved: (email) {},
            decoration: const InputDecoration(
              hintText: "Address",
              hintStyle: TextStyle(color: Colors.green),
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.add_business_outlined),
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
          const SizedBox(height: defaultPadding / 2),
          Container(
            width: 160,
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                _signUp();
              },
              child: Text(
                "Sign Up".toUpperCase(),
                style: TextStyle(color: kTextWhiteColor),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            login: false,
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const LoginScreen();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
