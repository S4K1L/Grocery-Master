import 'package:flutter/material.dart';
import '../../Drawer/admin_Drawer.dart';
import 'menu_post.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
         "Grocery Master",
         style: TextStyle(
           fontSize: 22,
           fontWeight: FontWeight.bold,
           color: Colors.green,
         ),
                    ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      drawer: AdminDrawer(),
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Expanded(
            child: MenuPost(),
          ),
        ],
      ),
    );
  }

}
