import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocerymaster/Presentation/Screens/Admin_Panel/Create_voucher/voucher_list.dart';
import '../../../../../Theme/const.dart';

class CreateVoucherPage extends StatefulWidget {
  const CreateVoucherPage({Key? key}) : super(key: key);

  @override
  State<CreateVoucherPage> createState() => _CreateVoucherPageState();
}

class _CreateVoucherPageState extends State<CreateVoucherPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _voucherNameController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();

  void _createVoucher() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String voucherName = _voucherNameController.text.trim();
    int discountAmount = int.parse(_discountController.text.trim());

    try {
      await FirebaseFirestore.instance.collection('vouchers').add({
        'name': voucherName,
        'discount': discountAmount,
        'code': voucherName.toLowerCase().replaceAll(' ', '_'),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Voucher created successfully!",
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

      _voucherNameController.clear();
      _discountController.clear();
    } catch (e) {
      _showErrorMessage("Failed to create voucher: $e");
    }
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
  void dispose() {
    _voucherNameController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Create Voucher"),
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VoucherListPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _voucherNameController,
                decoration: InputDecoration(
                  labelText: "Voucher Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a voucher name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _discountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Discount Amount",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a discount amount';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createVoucher,
                child: Text("Create Voucher",style: TextStyle(color: kTextWhiteColor),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
