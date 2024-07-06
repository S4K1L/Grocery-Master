import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import '../../../../Theme/const.dart';
import '../../Drawer/user_Drawer.dart';
import '../../Payment_Page/payment_method.dart';
import '../manu_model.dart';

class CheckOut extends StatefulWidget {
  final Map<String, int> quantities;

  const CheckOut({super.key, required this.quantities});

  @override
  _CheckOutState createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  double? _discountPercentage = 0.0;
  double discountMoney = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchUserDiscount();
  }

  Future<void> _fetchUserDiscount() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    if (user == null) {
      return;
    }
    final userUid = user.uid;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userUid).get();

    // Ensure the user's permission is approved before fetching the discount
    if (userDoc.get('permission') == 'Approved') {
      setState(() {
        _discountPercentage = (userDoc.get('discount') as num).toDouble();
      });
    } else {
      setState(() {
        _discountPercentage = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Spacer(),
            const Text(
              "Grocery Master",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Spacer(),
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.shopping_cart,
                  color: Colors.green,
                )),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      drawer: UserDrawer(),
      body: FutureBuilder<List<MenuModelWithQuantity>>(
        future: _getMenuItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No items in checkout.'));
          } else {
            final cartItems = snapshot.data!;
            double subTotal = 0;
            String menuId = '';
            for (var item in cartItems) {
              double price = item.menuModel.price;
              subTotal += price * item.quantity;
              menuId = item.menuModel.docId;
            }
            double deliveryFee = 2.0;
            double total = subTotal + deliveryFee;
            double discount = _discountPercentage != null ? (subTotal / 100) * _discountPercentage! : 0.0;
            discountMoney = discount;
            double totalWithDiscount = total - discount;
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return _buildCartItem(item.menuModel, item.quantity);
                      },
                    ),
                  ),
                  _buildPaymentDetails(subTotal, deliveryFee, discount, totalWithDiscount),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 55,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.green[600]),
                      child: TextButton(
                        onPressed: () {
                          _showCheckoutDialog(context, cartItems, totalWithDiscount, menuId);
                        },
                        child: const Text(
                          'CHECKOUT',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<List<MenuModelWithQuantity>> _getMenuItems() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    if (user == null) {
      return [];
    }
    final userUid = user.uid;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('checkout')
        .where('userUid', isEqualTo: userUid)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final moreImagesUrl = data['moreImagesUrl'] as List<dynamic>;

      // Ensure the price is treated as an integer
      double price = 0;
      if (data['price'] is int) {
        price = double.tryParse(data['price']) ?? 0.0;
      } else if (data['price'] is double) {
        price = data['price'];
      } else if (data['price'] is String) {
        price = double.tryParse(data['price']) ?? 0.0;
      }

      int quantity = data['quantity'] ?? 1;

      return MenuModelWithQuantity(
        menuModel: MenuModel(
          imageUrl: data['imageUrl'],
          name: data['name'],
          price: price,
          docId: doc.id,
          moreImagesUrl: moreImagesUrl.map((url) => url as String).toList(),
          isFav: true,
          details: data['details'],
          category: doc['category'],
          subDetails: doc['subDetails'],
        ),
        quantity: quantity,
      );
    }).toList();
  }

  Widget _buildCartItem(MenuModel item, int quantity) {
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
                item.imageUrl,
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
                    item.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'RM ${item.price}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Row(
                children: [
                  Column(
                    children: [
                      Text('x$quantity'),
                      const SizedBox(height: 10),
                      Text('RM ${item.price * quantity}'),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 18,
                    ),
                    onPressed: () => _deleteCartItem(item.docId),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteCartItem(String docId) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? user = auth.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('checkout')
          .doc(docId)
          .delete();

      setState(() {});
    } catch (e) {
      // Handle error
      print('Error deleting item: $e');
    }
  }

  Widget _buildPaymentDetails(
      double subTotal, double deliveryFee, double discount, double totalWithDiscount) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Payment Details",
            style: TextStyle(
                fontSize: 20,
                color: kTextBlackColor,
                fontWeight: FontWeight.bold,
                letterSpacing: 1),
          ),
          const SizedBox(
            height: 20,
          ),
          _buildPaymentDetailRow('Sub Total', subTotal),
          _buildPaymentDetailRow('Delivery Fee', deliveryFee),
          if (_discountPercentage != null && _discountPercentage! > 0)
            _buildPaymentDetailRow('Discount (${_discountPercentage!.toStringAsFixed(2)}%)', -discount),
          const Divider(),
          _buildPaymentDetailRow('Total', totalWithDiscount, isTotal: true),
        ],
      ),
    );
  }


  Widget _buildPaymentDetailRow(String label, double amount,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            'RM ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context, List<MenuModelWithQuantity> cartItems, double total, String menuId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Your Details'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your location';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => _handleCheckout(context, cartItems, total, discountMoney),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleCheckout(BuildContext context, List<MenuModelWithQuantity> cartItems, double total, double discount) async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    if (user == null) {
      return;
    }
    final userUid = user.uid;
    final random = Random();
    final orderId = random.nextInt(1000000).toString();

    final orderData = {
      'orderId': orderId,
      'name': _nameController.text,
      'phone': _phoneController.text,
      'location': _locationController.text,
      'discount': discount,
      'total': total,
      'status': 'Ongoing',
      'items': cartItems.map((item) {
        return {
          'name': item.menuModel.name,
          'price': item.menuModel.price,
          'docId': item.menuModel.docId,
          'quantity': item.quantity,
          'imageUrl': item.menuModel.imageUrl,
        };
      }).toList(),
      'timestamp': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('orders').doc(orderId).set(orderData);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentMethodSelection(orderId: orderId),
      ),
    );

    await _clearCheckoutItems(userUid);
    setState(() {});
  }

  Future<void> _clearCheckoutItems(String userUid) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('checkout')
        .where('userUid', isEqualTo: userUid)
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }
}

class MenuModelWithQuantity {
  final MenuModel menuModel;
  final int quantity;

  MenuModelWithQuantity({required this.menuModel, required this.quantity});
}
