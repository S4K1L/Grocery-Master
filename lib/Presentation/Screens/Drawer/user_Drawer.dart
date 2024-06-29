import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocerymaster/Presentation/Screens/profile/views/profile_view.dart';
import '../../../Core/Repository_and_Authentication/profile_image_picker.dart';
import '../../../Theme/const.dart';
import '../Bottom_bar/user_bottombar.dart';
import '../User_HomePage/Cart_Manu/cart_menu.dart';
import '../User_HomePage/checkout/chekout.dart';
import '../User_HomePage/My_Order/my_order.dart';
import '../User_HomePage/Order_History/order_history.dart';
import '../User_HomePage/favorite/favorite_screen.dart';

class UserDrawer extends StatefulWidget {
  const UserDrawer({super.key});

  @override
  State<UserDrawer> createState() => _UserDrawerState();
}

class _UserDrawerState extends State<UserDrawer> {
  Map<String, dynamic> userData = {};
  Map<String, int> _quantities = {};

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    try {
      String userUID = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDataSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userUID)
          .get();
      Map<String, dynamic> userDataMap =
          userDataSnapshot.data() as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          userData = userDataMap;
        });
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 4,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.green[300]),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: const Center(child: ProfileImagePicker()),
                ),
                const SizedBox(height: 10),
                Text(
                  userData['name'] ?? 'Loading...',
                  style: TextStyle(fontSize: 20, color: kTextWhiteColor,fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20,bottom: 20),
                child: Text('My Account',style: TextStyle(color: Colors.grey,fontSize: 22,fontWeight: FontWeight.bold),),
              ),
              _buildDrawerButton(
                context,
                icon: Icons.home_filled,
                label: 'My Home',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserBottom(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
               _buildDrawerButton(
                context,
                icon: Icons.person,
                label: 'My Profile',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileView(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildDrawerButton(
                context,
                icon: Icons.favorite,
                label: 'My Favorite',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FavoriteScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildDrawerButton(
                context,
                icon: Icons.shopping_cart,
                label: 'My Cart',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CartMenuPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildDrawerButton(
                context,
                icon: Icons.shopping_cart_checkout,
                label: 'My Orders',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyOrders(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildDrawerButton(
                context,
                icon: Icons.manage_history_rounded,
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
              const SizedBox(height: 16),
              _buildDrawerButton(
                context,
                icon: Icons.check_box_sharp,
                label: 'Checkout',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckOut(quantities: _quantities),
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

  Widget _buildDrawerButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        backgroundColor: Colors.transparent,
      ),
      child: Row(
        children: [
          Icon(icon, size: 36, color: Colors.green),
          const SizedBox(width: 30),
          Text(
            label,
            style: const TextStyle(
              fontSize: 22,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
