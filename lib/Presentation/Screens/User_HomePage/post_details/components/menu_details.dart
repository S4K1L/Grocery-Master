import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocerymaster/Theme/const.dart';
import '../../../../../Theme/styles.dart';
import '../../manu_model.dart';

class MenuDetails extends StatefulWidget {
  final MenuModel menu;

  const MenuDetails(this.menu, {super.key});

  @override
  _MenuDetailsState createState() => _MenuDetailsState();
}

class _MenuDetailsState extends State<MenuDetails> {
  double _averageRating = 0;
  int _totalRatings = 0;
  int _itemCount = 0;
  final Map<String, bool> _favorites = {};
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, int> _quantities = {};
  User? _user;
  late Stream<List<MenuModel>> _menuStream;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _fetchRatings();
  }


  void _increment(MenuModel menu) {
    setState(() {
      _itemCount++;
      _quantities[menu.docId] = _itemCount;
    });
  }

  void _decrement(MenuModel menu) {
    setState(() {
      if (_itemCount > 0) {
        _itemCount--;
        _quantities[menu.docId] = _itemCount;
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${menu.name} added to checkout!'),
          duration: Duration(seconds: 2),
        ),
      );
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

  Future<void> _fetchRatings() async {
    final ratingsSnapshot = await FirebaseFirestore.instance
        .collection('menu')
        .doc(widget.menu.docId)
        .collection('ratings')
        .get();

    if (ratingsSnapshot.docs.isNotEmpty) {
      double totalRating = 0;
      for (var doc in ratingsSnapshot.docs) {
        totalRating += doc['rating'];
      }
      setState(() {
        _totalRatings = ratingsSnapshot.docs.length;
        _averageRating = totalRating / _totalRatings;
      });
    }
  }

  void _toggleFavorite(MenuModel menu) async {
    if (_user == null) {
      // User not logged in, handle appropriately
      return;
    }
    final userUid = _user!.uid;

    setState(() {
      _favorites[menu.docId] = !(_favorites[menu.docId] ?? false);
    });

    if (_favorites[menu.docId]!) {
      await FirebaseFirestore.instance.collection('cart').add({
        'imageUrl': menu.imageUrl,
        'name': menu.name,
        'price': menu.price,
        'details': menu.details,
        'docId': menu.docId,
        'moreImagesUrl': menu.moreImagesUrl,
        'userUid': userUid,
      });
    } else {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('cart')
          .where('docId', isEqualTo: menu.docId)
          .where('userUid', isEqualTo: userUid)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final menu = widget.menu;
    bool isFavorite = _favorites[menu.docId] ?? false;
    return Scaffold(
      bottomNavigationBar: Container(
        color: Colors.grey[200],
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.lightGreen[300],
                ),
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border_sharp,
                    color: isFavorite ? Colors.red : Colors.green,
                  ),
                  onPressed: () {
                    _toggleFavorite(menu);
                  },
                ),
              ),
              SizedBox(width: 30),
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    onPressed: () => _addToCart(menu),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreen[600],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Add to Bucket',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              color: Colors.grey[200],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(appPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menu.name,
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'RM ${menu.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.lightGreen[600],
                            ),
                          ),
                          Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove_circle_outline, color: Colors.lightGreen[600],),
                                onPressed: () => _decrement(menu),
                              ),
                              Text(
                                _itemCount.toString().padLeft(2, '0'),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightGreen[600],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.add_circle_outline, color: Colors.lightGreen[600],),
                                onPressed: () => _increment(menu),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        menu.subDetails,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Details',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        menu.details,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: kTextBlackColor.withOpacity(0.6),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
