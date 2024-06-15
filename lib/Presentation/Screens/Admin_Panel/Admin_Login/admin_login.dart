import 'package:flutter/material.dart';
import '../../../../../Widgets/components/background.dart';
import '../../../../../Widgets/responsive.dart';
import '../../login_screen/Login/components/login_screen_top_image.dart';
import 'admin_LoginForm.dart';

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Background(
      child: Responsive(
        mobile: MobileLoginScreen(),
        desktop: Row(
          children: [
            Expanded(
              child: LoginScreenTopImage(),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 450,
                    child: AdminLoginForm(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MobileLoginScreen extends StatelessWidget {
  const MobileLoginScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        LoginScreenTopImage(),
        Row(
          children: [
            Spacer(),
            Expanded(
              flex: 8,
              child: AdminLoginForm(),
            ),
            Spacer(),
          ],
        ),
      ],
    );
  }
}
