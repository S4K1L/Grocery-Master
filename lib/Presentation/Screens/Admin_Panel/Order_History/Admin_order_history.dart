import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocerymaster/Presentation/Screens/Drawer/admin_Drawer.dart';


class AdminOrderHistory extends StatefulWidget {
  const AdminOrderHistory({super.key});

  @override
  _AdminOrderHistoryState createState() => _AdminOrderHistoryState();
}

class _AdminOrderHistoryState extends State<AdminOrderHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Spacer(),
            const Text(
              "Orders History",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon:  Icon(
                Icons.fastfood_sharp,
                color: Colors.green,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      drawer: const AdminDrawer(),
      body: FutureBuilder<List<Order>>(
        future: _getOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders available.'));
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

  Future<List<Order>> _getOrders() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('status', isEqualTo: 'Delivered')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final items = (data['items'] as List<dynamic>).map((itemData) {
        final item = itemData as Map<String, dynamic>;
        return OrderItem(
          name: item['name'],
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
          color: Colors.lightGreen[300],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: Text(
                'Order ID: ${order.orderId}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Total: RM ${order.total.toStringAsFixed(2)}\n'
                    'Location: ${order.location}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
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
                  subtitle: Text('Quantity: ${item.quantity}'),
                  trailing: Text(
                    order.status,
                    style: const TextStyle(fontSize: 16),
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
  String status;
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
  final int quantity;
  final String imageUrl;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.imageUrl,
  });
}
