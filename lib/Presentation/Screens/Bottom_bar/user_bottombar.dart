import 'package:flutter/material.dart';
import 'package:grocerymaster/Presentation/Screens/User_HomePage/Cart_Manu/cart_menu.dart';
import 'package:grocerymaster/Presentation/Screens/User_HomePage/user_Home_Screen.dart';

import '../User_HomePage/My_Order/my_order.dart';
import '../User_HomePage/Order_History/order_history.dart';
import '../profile/views/profile_view.dart';


class UserBottom extends StatefulWidget {
  const UserBottom({super.key});

  @override
  State<UserBottom> createState() => _BottomBarState();
}

class _BottomBarState extends State<UserBottom> {
  int index_color = 0;
  List Screen = [UserHomeScreen(),MyOrders(),OrderHistory(),ProfileView()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Screen[index_color],
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => const CartMenuPage()));
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.shopping_basket_outlined),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          height: 60,
          shape: CircularNotchedRectangle(),
          child: Padding(
            padding: const EdgeInsets.only(top: 7.5, bottom: 7.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      index_color = 0;
                    });
                  },
                  child: Icon(
                    Icons.home,
                    size: 30,
                    color: index_color == 0 ? Colors.green : Colors.grey,
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      index_color = 1;
                    });
                  },
                  child: Icon(
                    Icons.checklist,
                    size: 30,
                    color: index_color == 1 ? Colors.green : Colors.grey,
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      index_color = 2;
                    });
                  },
                  child: Icon(
                    Icons.history,
                    size: 30,
                    color: index_color == 2 ? Colors.green : Colors.grey,
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      index_color = 3;
                    });
                  },
                  child: Icon(
                    Icons.person_outline,
                    size: 30,
                    color: index_color == 3 ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}