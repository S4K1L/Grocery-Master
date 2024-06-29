import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocerymaster/Theme/const.dart';
import '../../Drawer/user_Drawer.dart';
import '../checkout/chekout.dart';
import '../manu_model.dart';

class CartMenuPage extends StatefulWidget {
  const CartMenuPage({super.key});

  @override
  _CartMenuPageState createState() => _CartMenuPageState();
}

class _CartMenuPageState extends State<CartMenuPage> {
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

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckOut(quantities: _quantities),
      ),
    );
  }

  Stream<List<MenuModel>> _fetchMenuFromFirebase() {
    if (_user == null) {
      // User not logged in, handle appropriately
      return Stream.empty();
    }
    final userUid = _user!.uid;
    return FirebaseFirestore.instance
        .collection('cart')
        .where('userUid', isEqualTo: userUid)
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
          isFav: true,
          details: doc['details'],
          category: doc['category'],
          subDetails: doc['subDetails'],
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

  void _addToCart(MenuModel menu) {
    setState(() {
      if (_quantities[menu.docId] != null && _quantities[menu.docId]! > 0) {
        // Item has been added to the cart with a positive quantity
        _storeCheckoutData(menu, _quantities[menu.docId]!);
      } else {
        // Ensure that an item added to the cart has a quantity of at least 1
        _quantities[menu.docId] = 1;
        _storeCheckoutData(menu, 1);
      }

      // Show Snackbar message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${menu.name} added to Checkout!'),
        duration: Duration(seconds: 2),
      ));
    });
  }

  void _storeCheckoutData(MenuModel menu, int quantity) async {
    if (_user != null) {
      final userUid = _user!.uid;
      final docId = FirebaseFirestore.instance.collection('checkout').doc().id;
      await FirebaseFirestore.instance.collection('checkout').doc(docId).set({
        'userUid': userUid,
        'menuId': menu.docId,
        'name': menu.name,
        'category': menu.category,
        'price': menu.price,
        'details': menu.details,
        'subDetails': menu.subDetails,
        'quantity': quantity,
        'imageUrl': menu.imageUrl,
        'moreImagesUrl': menu.moreImagesUrl,
      });
    }
  }

  Future<void> _deleteCartItem(MenuModel menu,String docId) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? user = auth.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('cart')
          .doc(docId)
          .delete();

      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${menu.name} removed from cart!'),
        duration: Duration(seconds: 2),
      ));
    } catch (e) {
      // Handle error
      print('Error deleting item: $e');
    }
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.green[100],
              ),
              child: IconButton(
                onPressed: () => _deleteCartItem(menu,menu.docId),
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: Colors.green,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  menu.imageUrl,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
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
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'RM ${menu.price}',
                    style: const TextStyle(
                      fontSize: 12,
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
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.green[600],
                          ),
                          child: Center(
                            child: IconButton(
                              icon: const Icon(Icons.remove, size: 16, color: kTextWhiteColor),
                              onPressed: () => _decrement(menu),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.green[600],
                          ),
                          child: Center(
                            child: IconButton(
                              icon: const Icon(Icons.add, size: 16, color: kTextWhiteColor),
                              onPressed: () => _increment(menu),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10), // Add some spacing between the row and the button
                  ElevatedButton(
                    onPressed: () => _addToCart(menu),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add',
                      style: TextStyle(
                        color: kTextWhiteColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10), // Add some spacing between the row and the button
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Spacer(),
            Text(
              'Grocery Master',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.green[500],
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                _navigateToCart();
              },
              icon: Icon(Icons.shopping_cart, color: Colors.green[500], size: 28),
            ),
          ],
        ),
        centerTitle: true,
      ),
      drawer: UserDrawer(),
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: StreamBuilder<List<MenuModel>>(
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
            ),
          ],
        ),
      ),
    );
  }
}
