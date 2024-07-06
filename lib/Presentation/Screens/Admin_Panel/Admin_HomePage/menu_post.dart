import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocerymaster/Presentation/Screens/User_HomePage/manu_model.dart';
import 'package:grocerymaster/Presentation/Screens/User_HomePage/post_details/details_screen.dart';
import '../../User_HomePage/Cart_Manu/menu_button.dart';
import '../Edit_menu/edit_menu.dart';
import 'Search_button/custom_search.dart';

class AdminMenuPost extends StatefulWidget {
  const AdminMenuPost({super.key});

  @override
  _AdminMenuPostState createState() => _AdminMenuPostState();
}

class _AdminMenuPostState extends State<AdminMenuPost> {
  late Stream<List<MenuModel>> _menuStream;
  String _searchText = '';
  String _selectedCategory = '';
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

  void _deleteMenu(MenuModel menu) async {
    await FirebaseFirestore.instance.collection('menu').doc(menu.docId).delete();
    setState(() {
      // Refresh the stream to update the UI
      _menuStream = _fetchMenuFromFirebase();
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

        return MenuModel(
          imageUrl: doc['imageUrl'],
          name: doc['name'],
          price: doc['price'],
          docId: doc.id,
          moreImagesUrl: imageUrlList.map((url) => url as String).toList(),
          isFav: doc['isFav'],
          details: doc['details'],
          category: doc['category'],
          subDetails: doc['subDetails'],
        );
      }).toList();
    });
  }

  Widget _buildMenu(BuildContext context, MenuModel menu) {
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
                            Icons.edit,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditMenuScreen(menu: menu),
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          icon: Icon(
                            Icons.delete_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            _deleteMenu(menu);
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
                          _selectedCategory = 'Vegetables';
                        });
                      }),
                  MenuButton(
                      logo: 'fruit',
                      title: 'Fruits',
                      color: Colors.lightGreen[600]!,
                      onPress: () {
                        setState(() {
                          _selectedCategory = 'Fruits';
                        });
                      }),
                  MenuButton(
                      logo: 'dairy',
                      title: 'Dairy',
                      color: Colors.brown,
                      onPress: () {
                        setState(() {
                          _selectedCategory = 'Dairy';
                        });
                      }),
                  MenuButton(
                      logo: 'protein',
                      title: 'Proteins',
                      color: Colors.amber[500]!,
                      onPress: () {
                        setState(() {
                          _selectedCategory = 'Proteins';
                        });
                      }),
                  MenuButton(
                      logo: 'grain',
                      title: 'Grains',
                      color: Colors.blueGrey,
                      onPress: () {
                        setState(() {
                          _selectedCategory = 'Grains';
                        });
                      }),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10,left: 30),
          child: Align(
              alignment: Alignment.topLeft,
              child: Text(_selectedCategory,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),)),
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
