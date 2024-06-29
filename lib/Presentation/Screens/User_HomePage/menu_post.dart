import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocerymaster/Presentation/Screens/User_HomePage/manu_model.dart';
import 'package:grocerymaster/Presentation/Screens/User_HomePage/post_details/details_screen.dart';
import 'Cart_Manu/menu_button.dart';
import 'Search_button/custom_search.dart';

class MenuPost extends StatefulWidget {
  const MenuPost({super.key});

  @override
  _MenuPostState createState() => _MenuPostState();
}

class _MenuPostState extends State<MenuPost> {
  late Stream<List<MenuModel>> _menuStream;
  String _searchText = '';
  String _selectedCategory = '';
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
    return FirebaseFirestore.instance
        .collection('menu')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final moreImagesUrl = doc['moreImagesUrl'];
        final imageUrlList =
        moreImagesUrl is List ? moreImagesUrl : [moreImagesUrl];

        bool isFav = false;
        if (_user != null) {
          FirebaseFirestore.instance
              .collection('favorite')
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
          category: doc['category'],
          subDetails: doc['subDetails'],
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
      child: Column(
        children: [
          Container(
            height: 190,
            width: 150,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), color: Colors.white),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    menu.imageUrl,
                    height: 100,
                    width: MediaQuery.of(context).size.width / 2.5,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Text(
                    menu.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    menu.subDetails,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20)),
                    color: Colors.lightGreen[600],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          'RM ${menu.price}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: IconButton(
                          icon: Icon(
                            Icons.add_circle_outline_sharp,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            _toggleCart(menu);
                          },
                        ),
                      ),
                      Expanded(
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

  void _toggleCart(MenuModel menu) async {
    if (_user == null) {
      // User not logged in, handle appropriately
      return;
    }
    final userUid = _user!.uid;


    final querySnapshot = await FirebaseFirestore.instance
        .collection('cart')
        .where('docId', isEqualTo: menu.docId)
        .where('userUid', isEqualTo: userUid)
        .get();

    if (querySnapshot.docs.isEmpty) {
      final docId = FirebaseFirestore.instance.collection('cart').doc().id;
      await FirebaseFirestore.instance.collection('cart').doc(docId).set({
          'imageUrl': menu.imageUrl,
          'name': menu.name,
          'price': menu.price,
          'details': menu.details,
          'subDetails': menu.subDetails,
          'category': menu.category,
          'docId': menu.docId,
          'moreImagesUrl': menu.moreImagesUrl,
          'userUid': userUid,
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
        await FirebaseFirestore.instance.collection('favorite').add({
          'imageUrl': menu.imageUrl,
          'name': menu.name,
          'price': menu.price,
          'details': menu.details,
          'subDetails': menu.subDetails,
          'category': menu.category,
          'docId': menu.docId,
          'moreImagesUrl': menu.moreImagesUrl,
          'userUid': userUid,
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${menu.name} added to Favorite!'),
          duration: Duration(seconds: 2),
        ));
      } else {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('favorite')
            .where('docId', isEqualTo: menu.docId)
            .where('userUid', isEqualTo: userUid)
            .get();

        for (var doc in querySnapshot.docs) {
          await doc.reference.delete();
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${menu.name} removed from Favorite!'),
          duration: Duration(seconds: 2),
        ));

      }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchField(onSearch: _onSearch),
        const SizedBox(height: 20),
        SizedBox(
          height: 120, // Adjust the height as needed
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Row(
                children: [
                  MenuButton(
                      logo: 'all',
                      title: 'All',
                      color: Colors.grey,
                      onPress: () {
                        setState(() {
                          _selectedCategory = '';
                        });
                      }),
                  MenuButton(
                      logo: 'vegetable',
                      title: 'Veg',
                      color: Colors.green[300]!,
                      onPress: () {
                        setState(() {
                          _selectedCategory = 'vegetable';
                        });
                      }),
                  MenuButton(
                      logo: 'fruit',
                      title: 'Fruits',
                      color: Colors.lightGreen[600]!,
                      onPress: () {
                        setState(() {
                          _selectedCategory = 'fruit';
                        });
                      }),
                  MenuButton(
                      logo: 'dairy',
                      title: 'Dairy',
                      color: Colors.brown,
                      onPress: () {
                        setState(() {
                          _selectedCategory = 'dairy';
                        });
                      }),
                  MenuButton(
                      logo: 'protein',
                      title: 'Proteins',
                      color: Colors.amber[500]!,
                      onPress: () {
                        setState(() {
                          _selectedCategory = 'protein';
                        });
                      }),
                  MenuButton(
                      logo: 'grain',
                      title: 'Grains',
                      color: Colors.blueGrey,
                      onPress: () {
                        setState(() {
                          _selectedCategory = 'grain';
                        });
                      }),
                ],
              ),
              IconButton(
                alignment: Alignment.topRight,
                onPressed: () {},
                icon: Icon(Icons.filter_list, color: Colors.green),
              )
            ],
          ),
        ),
        Flexible(
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
                      .where((menu) =>
                  _matchesSearchText(menu) &&
                      (menu.category == _selectedCategory ||
                          _selectedCategory.isEmpty))
                      .toList();
                  if (filteredMenu.isNotEmpty) {
                    return GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Number of posts per line
                        crossAxisSpacing: 0,
                        mainAxisSpacing: 0.0,
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
