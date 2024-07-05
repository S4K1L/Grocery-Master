import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../Theme/const.dart';

class VoucherListPage extends StatelessWidget {
  const VoucherListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Vouchers List"),
        backgroundColor: kPrimaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('vouchers').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No vouchers found."));
          }

          final vouchers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: vouchers.length,
            itemBuilder: (context, index) {
              final voucher = vouchers[index];
              final voucherData = voucher.data() as Map<String, dynamic>;
              final voucherName = voucherData['name'] ?? 'No name';
              final discount = voucherData['discount'] ?? '0';

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.green[300]
                  ),
                  child: ListTile(
                    title: Text('Voucher Code: ${voucherName}'),
                    subtitle: Text('Discount: $discount%'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
