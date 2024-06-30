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
      backgroundColor: Colors.grey[300],
      appBar: AppBar(title: Text('Enter Payment Details',style: TextStyle(color: Colors.green),),
        backgroundColor: Colors.grey[300],),
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
                    if (widget.paymentMethod == 'Credit Card') ...[
                      formWidget('Card Number',cardNumberController),
                      SizedBox(height: 20),
                      formWidget('Cardholder\'s Name',cardHolderNameController),
                      SizedBox(height: 20),
                      Row(
                        children: [
                        SizedBox(
                        width: MediaQuery.of(context).size.width /2.5,
                        child: TextFormField(
                          controller: expireController,
                          decoration: InputDecoration(
                            labelText: 'Expiration Date',
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
                      ),
                          Spacer(),
                          SizedBox(
                          width: MediaQuery.of(context).size.width /2.5,
                        child: TextFormField(
                          controller: cvvController,
                          decoration: InputDecoration(
                            labelText: 'CVV',
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
                      ),
                        ],
                      ),
                      SizedBox(height: 20),
                      ButtonWidget(onPress: (){}, title: 'Confirm & Pay',)
                    ],
                    if (widget.paymentMethod == 'Debit Card') ...[
                      formWidget('Debit Number',cardNumberController),
                      SizedBox(height: 20),
                      formWidget('Cardholder\'s Name',cardHolderNameController),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width /2.5,
                            child: TextFormField(
                              controller: expireController,
                              decoration: InputDecoration(
                                labelText: 'Expiration Date',
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
                          ),
                          Spacer(),
                          SizedBox(
                            width: MediaQuery.of(context).size.width /2.5,
                            child: TextFormField(
                              controller: cvvController,
                              decoration: InputDecoration(
                                labelText: 'CVV',
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
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      ButtonWidget(onPress: (){}, title: 'Confirm & Pay',)
                    ],
                    if (widget.paymentMethod == 'Net Banking') ...[
                      formWidget('Account Number',cardNumberController),
                      SizedBox(height: 20),
                      formWidget('Account holder\'s Name',cardHolderNameController),
                      SizedBox(height: 20),
                      ButtonWidget(onPress: (){}, title: 'Confirm & Pay',)
                    ],
                    if (widget.paymentMethod == 'Cash on Delivery') ...[
                      formWidget('Full Name',cardNumberController),
                      SizedBox(height: 20),
                      formWidget('Phone',cardHolderNameController),
                      SizedBox(height: 20),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: TextFormField(
                          controller: expireController,
                          decoration: InputDecoration(
                            labelText: 'Address',
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
                      ),
                      SizedBox(height: 20),
                      ButtonWidget(onPress: (){}, title: 'Confirm',)
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
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
