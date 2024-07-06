import 'package:flutter/material.dart';
import 'package:grocerymaster/Presentation/Screens/Payment_Page/payment_details.dart';

import '../../../Theme/const.dart';

class PaymentMethodSelection extends StatefulWidget {
  final String orderId;


  PaymentMethodSelection({required this.orderId});
  @override
  _PaymentMethodSelectionState createState() => _PaymentMethodSelectionState();
}

class _PaymentMethodSelectionState extends State<PaymentMethodSelection> {
  String _selectedMethod = 'Credit Card';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        centerTitle: true,
        title: const Text(
          'Payment Method',
          style: TextStyle(color: Colors.green),
        ),
      ),
      backgroundColor: Colors.grey[300],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: kTextWhiteColor,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildHeader(),
                  _buildPaymentOption('Credit Card'),
                  _buildPaymentOption('Debit Card'),
                  _buildPaymentOption('Net Banking'),
                  _buildPaymentOption('Cash on Delivery'),
                  _buildPaypalOption(),
                  const SizedBox(height: 20),
                  _buildProceedButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 30, bottom: 10),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Text(
          'Enter Payment Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: kTextBlackColor,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String method) {
    return RadioListTile(
      title: Text(
        method,
        style: TextStyle(fontWeight: FontWeight.normal),
      ),
      value: method,
      groupValue: _selectedMethod,
      onChanged: (value) {
        setState(() {
          _selectedMethod = value.toString();
        });
      },
    );
  }

  Widget _buildPaypalOption() {
    return RadioListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/paypal.png',
            width: 80,
            height: 80,
          ),
        ],
      ),
      value: 'Paypal',
      groupValue: _selectedMethod,
      onChanged: (value) {
        setState(() {
          _selectedMethod = value.toString();
        });
      },
    );
  }

  Widget _buildProceedButton(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.3,
      height: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.green,
      ),
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PaymentDetailsPage(paymentMethod: _selectedMethod,orderId: widget.orderId, docId: '',),
            ),
          );
        },
        child: Text(
          'Proceed Next',
          style: TextStyle(color: kTextWhiteColor),
        ),
      ),
    );
  }
}
