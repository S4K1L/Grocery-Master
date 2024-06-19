import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocerymaster/Presentation/Screens/User_HomePage/manu_model.dart';
import 'package:grocerymaster/Presentation/Screens/User_HomePage/post_details/details_screen.dart';
import 'Search_button/custom_search.dart';

class MenuPost extends StatefulWidget {
  const MenuPost({super.key});

  @override
  _MenuPostState createState() => _MenuPostState();
}

class _MenuPostState extends State<MenuPost> {
  late Stream<List<MenuModel>> _menuStream;
  String _searchText = '';
  final Map<String, bool> _favorites = {};
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _menuStream = _fetchMenuFromFirebase();
  }

  void _onSearch(String searchText) {
    setState(() {
      _searchText = searchText;
    });
  }

  Stream<List<MenuModel>> _fetchMenuFromFirebase() {
    return FirebaseFirestore.instance.collection('menu').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final moreImagesUrl = doc['moreImagesUrl'];
        final imageUrlList = moreImagesUrl is List ? moreImagesUrl : [moreImagesUrl];

        bool isFav = false;
        if (_user != null) {
          FirebaseFirestore.instance.collection('cart')
              .where('userUid', isEqualTo: _user!.uid)
              .where('docId', isEqualTo: doc.id)
              .get()
              .then((value) {
            if (value.docs.isNotEmpty) {
              setState(() {
                _favorites[doc.id] = true;
              });
            }
          });
        }

        return MenuModel(
          imageUrl: doc['imageUrl'],
          name: doc['name'],
          price: doc['price'],
          docId: doc.id,
          moreImagesUrl: imageUrlList.map((url) => url as String).toList(),
          isFav: isFav,
          details: doc['details'],
        );
      }).toList();
    });
  }

  Widget _buildMenu(BuildContext context, MenuModel menu) {
    bool isFavorite = _favorites[menu.docId] ?? false;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailsScreen(menu: menu),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.green[200],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      menu.imageUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.green.withOpacity(0.9),
                      ),
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.white,
                        ),
                        onPressed: () {
                          _toggleFavorite(menu);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, top: 3),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          menu.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'RM ${menu.price}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    return Column(
      children: [
        SearchField(onSearch: _onSearch),
        const SizedBox(height: 20),
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
                List<MenuModel>? menus = snapshot.data;
                if (menus != null && menus.isNotEmpty) {
                  List<MenuModel> filteredMenu = menus
                      .where((menu) => _matchesSearchText(menu))
                      .toList();
                  if (filteredMenu.isNotEmpty) {
                    return GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Number of posts per line
                        crossAxisSpacing: 4.0,
                        mainAxisSpacing: 20.0,
                        childAspectRatio:
                        0.95, // Adjust the aspect ratio as needed
                      ),
                      itemCount: filteredMenu.length,
                      itemBuilder: (context, index) {
                        return _buildMenu(context, filteredMenu[index]);
                      },
                    );
                  } else {
                    return const Center(
                      child: Text('No matching items found.'),
                    );
                  }
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
    );
  }

  bool _matchesSearchText(MenuModel menu) {
    String searchText = _searchText.toLowerCase();
    List<String> searchTerms = searchText.split(' ');

    return searchTerms.every((term) =>
    menu.name.toLowerCase().contains(term) ||
        menu.price.toString().contains(term));
  }
}
