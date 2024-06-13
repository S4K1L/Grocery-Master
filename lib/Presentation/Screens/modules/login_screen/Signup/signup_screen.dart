import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../../../Core/Firebase/Auth.dart';
import '../../../../../Widgets/components/background.dart';
import '../../../../../Widgets/components/constants.dart';
import '../../../../../Widgets/responsive.dart';
import '../../../routes/app_pages.dart';
import 'components/sign_up_top_image.dart';
import 'components/signup_form.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  @override
  Widget build(BuildContext context) {
    return const Background(
      child: SingleChildScrollView(
        child: Responsive(
          mobile: MobileSignupScreen(),
          desktop: Row(
            children: [
              Expanded(
                child: SignUpScreenTopImage(),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 450,
                      child: SignUpForm(),
                    ),
                    SizedBox(height: defaultPadding / 2),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MobileSignupScreen extends StatelessWidget {
  const MobileSignupScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SignUpScreenTopImage(),
          Row(
            children: [
              Spacer(),
              Expanded(
                flex: 8,
                child: SignUpForm(),
              ),
              Spacer(),
            ],
          ),
          // const SocalSignUp()
        ],
      ),
    );
  }
}
