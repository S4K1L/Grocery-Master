import 'package:flutter/material.dart';

import '../../../Theme/const.dart';
import '../../utils/button.dart';

class PaymentDetailsPage extends StatefulWidget {
  final String paymentMethod;

  PaymentDetailsPage({required this.paymentMethod});

  @override
  State<PaymentDetailsPage> createState() => _PaymentDetailsPageState();
}

class _PaymentDetailsPageState extends State<PaymentDetailsPage> {
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardHolderNameController = TextEditingController();
  final TextEditingController expireController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter Payment Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (widget.paymentMethod == 'Credit Card') ...[
              formWidget('Card Number',cardNumberController),
              SizedBox(height: 20),
              formWidget('Cardholder\'s Name',cardHolderNameController),
              SizedBox(height: 20),
              formWidget('Expiration Date',expireController),
              SizedBox(height: 20),
              formWidget('CVV',cvvController),
              SizedBox(height: 20),
              ButtonWidget(onPress: (){}, title: 'Confirm & Pay',)
            ],
            if (widget.paymentMethod != 'Credit Card') ...[
              Center(child: Text('Selected payment method: ${widget.paymentMethod}')),
            ],
          ],
        ),
      ),
    );
  }

  SizedBox formWidget(String title, TextEditingController controller) {
    return SizedBox(
      width: double.infinity,
      child: TextFormField(
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
      ),
    );
  }
}
