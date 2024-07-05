import 'dart:io';
import 'dart:ui' as ui;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../Core/Repository_and_Authentication/custom_buttons.dart';
import '../../../../Theme/const.dart';

class Membership extends StatefulWidget {
  const Membership({super.key});

  @override
  State<Membership> createState() => _MembershipState();
}

class _MembershipState extends State<Membership> {
  Map<String, dynamic> userData = {};
  final TextEditingController _voucherController = TextEditingController();
  String discountMessage = '';

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  Future<void> getUserData() async {
    try {
      String userUID = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDataSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userUID)
          .get();
      Map<String, dynamic> userDataMap = userDataSnapshot.data() as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          userData = userDataMap;
        });
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  Future<void> applyVoucher() async {
    String voucherCode = _voucherController.text.trim();
    try {
      if (userData['usedVouchers'] != null && userData['usedVouchers'].contains(voucherCode)) {
        setState(() {
          discountMessage = 'Voucher code already used';
        });
        return;
      }

      QuerySnapshot voucherSnapshot = await FirebaseFirestore.instance
          .collection('vouchers')
          .where('code', isEqualTo: voucherCode)
          .get();

      if (voucherSnapshot.docs.isNotEmpty) {
        var voucherData = voucherSnapshot.docs.first.data() as Map<String, dynamic>;
        int discountAmount = voucherData['discount'];

        String userUID = FirebaseAuth.instance.currentUser!.uid;

        // Update user's discount and QR code
        await FirebaseFirestore.instance.collection('users').doc(userUID).update({
          'discount': discountAmount,
          'usedVouchers': FieldValue.arrayUnion([voucherCode]),
        });

        String qrCodeUrl = await _generateQRCodeAndUpload(userUID, discountAmount);

        await FirebaseFirestore.instance.collection('users').doc(userUID).update({
          'qrCodeUrl': qrCodeUrl,
        });

        setState(() {
          discountMessage = 'Discount applied: \$${discountAmount}';
          userData['qrCodeUrl'] = qrCodeUrl;
        });
      } else {
        setState(() {
          discountMessage = 'Invalid voucher code';
        });
      }
    } catch (error) {
      print('Error applying voucher: $error');
      setState(() {
        discountMessage = 'Error applying voucher';
      });
    }
  }

  Future<String> _generateQRCodeAndUpload(String userUID, int discount) async {
    // Collect user data
    final userData = {
      "name": this.userData['name'],
      "phone": this.userData['phone'],
      "email": this.userData['email'],
      "address": this.userData['address'],
      "discount": '$discount',
      "permission": this.userData['permission'] ?? 'Denied',
    };
    final userDataString = userData.entries.map((e) => '${e.key}: ${e.value}').join('\n');

    final tempDir = await getTemporaryDirectory();
    final qrCodeFile = File('${tempDir.path}/qr_code.png');
    final qrValidationPainter = QrPainter(
      data: userDataString,
      version: QrVersions.auto,
      gapless: true,
    );

    final picData = await qrValidationPainter.toImageData(200);
    await qrCodeFile.writeAsBytes(picData!.buffer.asUint8List());

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('qr_codes/${DateTime.now().millisecondsSinceEpoch}.png');

    final uploadTask = storageRef.putFile(qrCodeFile);
    final snapshot = await uploadTask;
    final qrCodeUrl = await snapshot.ref.getDownloadURL();

    return qrCodeUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 8,
            padding: const EdgeInsets.all(kDefaultPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back_ios_new, color: Colors.green),
                    ),
                    Spacer(),
                    Text(
                      "Membership",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: kPrimaryColor),
                    ),
                    Spacer(),
                    Icon(Icons.error, color: kPrimaryColor),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: kOtherColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          kHalfSizeBox,
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                if (userData['qrCodeUrl'] != null)
                                  Image.network(
                                    userData['qrCodeUrl'],
                                    width: 250,
                                    height: 250,
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: 200),
                          TextFormField(
                            controller: _voucherController,
                            decoration: InputDecoration(
                              labelText: 'Enter Voucher Code',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 20),
                          CustomButton(
                            onPress: applyVoucher,
                            title: "Apply Voucher",
                          ),
                          SizedBox(height: 20),
                          Text(
                            discountMessage,
                            style: TextStyle(color: Colors.green, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
