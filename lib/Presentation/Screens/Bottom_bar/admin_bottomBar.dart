import 'package:flutter/material.dart';
import 'package:grocerymaster/Presentation/Screens/Admin_Panel/Admin_HomePage/Admin_Home_Screen.dart';
import 'package:grocerymaster/Presentation/Screens/Admin_Panel/Create_Menu/create_menu.dart';
import '../Admin_Panel/New_Order/new_order.dart';
import '../Admin_Panel/Order_History/Admin_order_history.dart';
import '../profile/views/profile_view.dart';


class AdminBottom extends StatefulWidget {
  const AdminBottom({super.key});
  static String routeName = 'AdminBottom';

  @override
  State<AdminBottom> createState() => _BottomBarState();
}

class _BottomBarState extends State<AdminBottom> {
  int index_color = 0;
  List Screen = [AdminHomeScreen(),NewOrders(),AdminOrderHistory(),ProfileView()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Screen[index_color],
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => const CreateMenu()));
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
                    Icons.restaurant_menu,
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