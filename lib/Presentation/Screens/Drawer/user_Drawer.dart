import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocerymaster/Presentation/Screens/login_screen/Login/login_screen.dart';
import '../../../Core/Repository_and_Authentication/profile_image_picker.dart';
import '../../../Theme/const.dart';
import '../Bottom_bar/user_bottombar.dart';
import '../User_HomePage/Cart_Manu/cart_menu.dart';
import '../User_HomePage/My_Order/my_order.dart';
import '../User_HomePage/Order_History/order_history.dart';
import '../User_HomePage/user_Home_Screen.dart';


class UserDrawer extends StatelessWidget {
  const UserDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 3.5,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.green[300]
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: const Center(child: ProfileImagePicker()),
                ),
                const SizedBox(height: 20),
                const Text(
                  'My Profile',
                  style: TextStyle(fontSize: 20, color: kTextBlackColor),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              _buildDrawerButton(
                context,
                icon: Icons.home_outlined,
                label: 'Home',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserBottom(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildDrawerButton(
                context,
                icon: Icons.shopping_cart_outlined,
                label: 'Cart',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CartMenuPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildDrawerButton(
                context,
                icon: Icons.edit_note,
                label: 'My Order',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyOrders(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildDrawerButton(
                context,
                icon: Icons.checklist,
                label: 'Order History',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrderHistory(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildDrawerButton(
                context,
                icon: Icons.logout,
                label: 'Logout',
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onPressed}) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        backgroundColor: Colors.transparent,
      ),
      child: Row(
        children: [
          Icon(icon, size: 36, color: kTextBlackColor),
          const SizedBox(width: 30),
          Text(
            label,
            style: const TextStyle(
              fontSize: 22,
              color: kTextBlackColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
