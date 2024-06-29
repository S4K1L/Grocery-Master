import 'package:flutter/material.dart';
import 'package:grocerymaster/Presentation/Screens/Payment_Page/payment_details.dart';

import '../../../Theme/const.dart';

class PaymentMethodSelection extends StatefulWidget {
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 100,left: 20,right: 20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: kTextWhiteColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 30,bottom: 10),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                          child: Text(
                        'Enter Payment Details',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kTextBlackColor,
                          fontSize: 18
                        ),
                      )),
                    ),
                    RadioListTile(
                      title: Text('Credit Card',style: TextStyle(fontWeight: FontWeight.normal),),
                      value: 'Credit Card',
                      groupValue: _selectedMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedMethod = value.toString();
                        });
                      },
                    ),
                    RadioListTile(
                      title: Text('Debit Card',style: TextStyle(fontWeight: FontWeight.normal),),
                      value: 'Debit Card',
                      groupValue: _selectedMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedMethod = value.toString();
                        });
                      },
                    ),
                    RadioListTile(
                      title: Text('Net Banking',style: TextStyle(fontWeight: FontWeight.normal),),
                      value: 'Net Banking',
                      groupValue: _selectedMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedMethod = value.toString();
                        });
                      },
                    ),
                    RadioListTile(
                      title: Text('Cash on Delivery',style: TextStyle(fontWeight: FontWeight.normal),),
                      value: 'Cash on Delivery',
                      groupValue: _selectedMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedMethod = value.toString();
                        });
                      },
                    ),
                    RadioListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset('assets/images/paypal.png',width: 80,height: 80,),
                        ],
                      ),
                      value: 'Paypal',
                      groupValue: _selectedMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedMethod = value.toString();
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: MediaQuery.of(context).size.width/1.3,
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
                                  PaymentDetailsPage(paymentMethod: _selectedMethod),
                            ),
                          );
                        },
                        child: Text('Proceed Next',style: TextStyle(color: kTextWhiteColor),),
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
