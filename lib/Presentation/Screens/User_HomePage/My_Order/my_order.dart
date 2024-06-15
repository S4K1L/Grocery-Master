import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Drawer/user_Drawer.dart';

class MyOrders extends StatefulWidget {
  const MyOrders({super.key});

  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Spacer(),
             Text(
              "My Orders",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[500],
              ),
            ),
            const Spacer(),
            IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.shopping_cart,
                  color: Colors.green[500],
                ))
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      drawer: UserDrawer(),
      body: FutureBuilder<List<Order>>(
        future: _getOngoingOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No ongoing orders.'));
          } else {
            final orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _buildOrderItem(order);
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Order>> _getOngoingOrders() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    if (user == null) {
      return [];
    }
    final userUid = user.uid;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('userUid', isEqualTo: userUid)
        .where('status', isEqualTo: 'Ongoing')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final items = (data['items'] as List<dynamic>).map((itemData) {
        final item = itemData as Map<String, dynamic>;
        return OrderItem(
          name: item['name'],
          price: item['price'],
          quantity: item['quantity'],
          imageUrl: item['imageUrl'],
        );
      }).toList();

      return Order(
        orderId: data['orderId'],
        userUid: data['userUid'],
        name: data['name'],
        phone: data['phone'],
        location: data['location'],
        total: data['total'].toDouble(),
        status: data['status'],
        items: items,
      );
    }).toList();
  }

  Widget _buildOrderItem(Order order) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.green[200],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.items.length,
              itemBuilder: (context, index) {
                final item = order.items[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      item.imageUrl,
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(item.name),
                  subtitle: Text('Quantity: ${item.quantity}',style: TextStyle(fontSize: 14),),
                  trailing: Column(
                    children: [
                      Text(
                        'ORDER: ${order.orderId}',
                        style: const TextStyle(fontSize: 14),
                      ),

                      Text(
                        'RM ${(item.price * item.quantity).toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 13),
                      ),

                      Text(
                        order.status,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Order {
  final String orderId;
  final String userUid;
  final String name;
  final String phone;
  final String location;
  final double total;
  final String status;
  final List<OrderItem> items;

  Order({
    required this.orderId,
    required this.userUid,
    required this.name,
    required this.phone,
    required this.location,
    required this.total,
    required this.status,
    required this.items,
  });
}

class OrderItem {
  final String name;
  final int price;
  final int quantity;
  final String imageUrl;

  OrderItem({
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });
}
