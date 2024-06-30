import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../Theme/const.dart';
import '../Bottom_bar/user_bottombar.dart';
import '../User_HomePage/checkout/chekout.dart';

class PaymentDetailsPage extends StatefulWidget {
  final String orderId;
  final String paymentMethod;

  PaymentDetailsPage({required this.paymentMethod, required this.orderId});

  @override
  State<PaymentDetailsPage> createState() => _PaymentDetailsPageState();
}

class _PaymentDetailsPageState extends State<PaymentDetailsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardHolderNameController = TextEditingController();
  final TextEditingController expireController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final List<MenuModelWithQuantity> cartItems = [];
  double total = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text(
          'Enter Payment Details',
          style: TextStyle(color: Colors.green),
        ),
        backgroundColor: Colors.grey[300],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: kTextWhiteColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (widget.paymentMethod == 'Credit Card' || widget.paymentMethod == 'Debit Card') ...[
                      _formField('Card Number', cardNumberController),
                      SizedBox(height: 20),
                      _formField('Cardholder\'s Name', cardHolderNameController),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _formField('Expiration Date', expireController),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: _formField('CVV', cvvController),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      _confirmButton(context),
                    ],
                    if (widget.paymentMethod == 'Net Banking' || widget.paymentMethod == 'Paypal') ...[
                      _formField('Account Number', cardNumberController),
                      SizedBox(height: 20),
                      _formField('Account holder\'s Name', cardHolderNameController),
                      SizedBox(height: 20),
                      _confirmButton(context),
                    ],
                    if (widget.paymentMethod == 'Cash on Delivery') ...[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: kTextWhiteColor,
                        ),
                        child: Column(
                          children: [
                            Text(
                              'You are ready to go',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      _confirmButton(context),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _formField(String title, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );
  }

  Widget _confirmButton(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.3,
      height: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.green,
      ),
      child: TextButton(
        onPressed: () => _uploadData(context),
        child: Text(
          'Confirm',
          style: TextStyle(color: kTextWhiteColor),
        ),
      ),
    );
  }

  Future<void> _uploadData(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }
      final paymentData = {
        "paymentMethod": widget.paymentMethod,
        "cardNumber": cardNumberController.text,
        "cardHolderName": cardHolderNameController.text,
        "expireDate": expireController.text,
        "cvv": cvvController.text,
        "timestamp": FieldValue.serverTimestamp(),
      };

      final orderData = {
        "userId": user.uid,
        "paymentData": paymentData,
      };

      final orderCollection = FirebaseFirestore.instance.collection('orders').doc(widget.orderId);

      await orderCollection.set(orderData, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Payment successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserBottom(), // Navigate to the checkout page
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to upload payment details: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
