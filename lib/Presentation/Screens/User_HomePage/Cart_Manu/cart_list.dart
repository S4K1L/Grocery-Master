import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Admin_Panel/Admin_HomePage/manu_model.dart';
import 'chekout.dart';



class CartList extends StatefulWidget {
  const CartList({super.key});

  @override
  State<CartList> createState() => _CartListState();
}

class _CartListState extends State<CartList> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  late Stream<List<MenuModel>> _menuStream;
  Map<String, int> _quantities = {};

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _menuStream = _fetchMenuFromFirebase();
  }

  Stream<List<MenuModel>> _fetchMenuFromFirebase() {
    if (_user == null) {
      return Stream.empty();
    }
    final userUid = _user!.uid;
    return FirebaseFirestore.instance
        .collection('menu')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final moreImagesUrl = doc['moreImagesUrl'];
        final imageUrlList = moreImagesUrl is List
            ? moreImagesUrl
            : [moreImagesUrl]; // Ensure it's always a list

        return MenuModel(
          imageUrl: doc['imageUrl'],
          name: doc['name'],
          price: doc['price'],
          docId: doc.id,
          moreImagesUrl: imageUrlList.map((url) => url as String).toList(),
          isFav: false, // Change this if needed
        );
      }).toList();
    });
  }

  void _increment(MenuModel menu) {
    setState(() {
      _quantities[menu.docId] = (_quantities[menu.docId] ?? 0) + 1;
    });
  }

  void _decrement(MenuModel menu) {
    setState(() {
      if ((_quantities[menu.docId] ?? 0) > 0) {
        _quantities[menu.docId] = (_quantities[menu.docId]! - 1);
      }
    });
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckOut(quantities: _quantities),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QuickBites Food'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: _navigateToCart,
          ),
        ],
      ),
      body: StreamBuilder<List<MenuModel>>(
        stream: _menuStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            List<MenuModel>? menuItems = snapshot.data;
            if (menuItems != null && menuItems.isNotEmpty) {
              return ListView.builder(
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  return _buildMenuItem(context, menuItems[index]);
                },
              );
            } else {
              return const Center(
                child: Text('No items available.'),
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, MenuModel menu) {
    int quantity = _quantities[menu.docId] ?? 0;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                menu.imageUrl,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'RM ${menu.price}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 30),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.purple[300],
                        ),
                        child: Center(
                          child: IconButton(
                            icon: const Icon(Icons.remove, size: 16),
                            onPressed: () => _decrement(menu),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('$quantity'),
                      const SizedBox(width: 10),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.purple[300],
                        ),
                        child: Center(
                          child: IconButton(
                            icon: const Icon(Icons.add, size: 16),
                            onPressed: () => _increment(menu),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10), // Add some spacing between the row and the button
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
