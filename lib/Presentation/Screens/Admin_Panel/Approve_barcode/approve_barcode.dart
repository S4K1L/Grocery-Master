import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:barcode/barcode.dart';
import '../../../../../Theme/const.dart';

class ApproveBarcodePage extends StatefulWidget {
  const ApproveBarcodePage({Key? key}) : super(key: key);

  @override
  State<ApproveBarcodePage> createState() => _ApproveBarcodePageState();
}

class _ApproveBarcodePageState extends State<ApproveBarcodePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _updatePermission(String userId, String permission) async {
    try {
      await _firestore.collection('users').doc(userId).update({'permission': permission});
      String barcodeUrl = await _generateBarcodeAndUpload(userId, permission);
      await _firestore.collection('users').doc(userId).update({'barcodeUrl': barcodeUrl});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Permission and Barcode updated successfully!",
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 6,
        ),
      );
    } catch (e) {
      _showErrorMessage("Failed to update permission: $e");
    }
  }

  Future<String> _generateBarcodeAndUpload(String userId, String permission) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

    // Collect user data for Barcode
    final barcodeData = {
      "name": userData['name'],
      "phone": userData['phone'],
      "email": userData['email'],
      "address": userData['address'],
      "discount": userData['discount'].toString(),
      "permission": permission,
    };
    final barcodeDataString = barcodeData.entries.map((e) => '${e.key}: ${e.value}').join('\n');

    // Generate the barcode using PDF417
    final barcode = Barcode.pdf417();
    final svg = barcode.toSvg(barcodeDataString, width: 200, height: 80);

    final tempDir = await getTemporaryDirectory();
    final barcodeFile = File('${tempDir.path}/barcode.svg');
    await barcodeFile.writeAsString(svg);

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('barcodes/${DateTime.now().millisecondsSinceEpoch}.svg');

    final uploadTask = storageRef.putFile(barcodeFile);
    final snapshot = await uploadTask;
    final barcodeUrl = await snapshot.ref.getDownloadURL();

    return barcodeUrl;
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 6,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Approve Barcodes"),
        backgroundColor: kPrimaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').where('type', isEqualTo: 'user').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return Center(child: Text("No users found."));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final userData = user.data() as Map<String, dynamic>;
              final userName = userData['name'] ?? 'No name';
              final discount = userData['discount'] ?? '0';
              final permission = userData['permission'] ?? 'Denied';

              return ListTile(
                title: Text(userName),
                subtitle: Text('Discount: $discount%'),
                trailing: DropdownButton<String>(
                  value: permission,
                  items: ['Approved', 'Denied'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      _updatePermission(user.id, newValue);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
