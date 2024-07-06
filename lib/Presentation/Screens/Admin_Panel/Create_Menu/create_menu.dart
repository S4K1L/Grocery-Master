import 'dart:io';
import 'package:flutter/material.dart';
import 'package:grocerymaster/Theme/const.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../Drawer/admin_Drawer.dart';

class CreateMenu extends StatefulWidget {
  const CreateMenu({super.key});

  static String routeName = 'CreateMenu';

  @override
  _CreateMenuState createState() => _CreateMenuState();
}

class _CreateMenuState extends State<CreateMenu> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _detailsController = TextEditingController();
  TextEditingController _subDetailsController = TextEditingController();

  List<File> _images = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String category = '';

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(
      maxWidth: 800,
      maxHeight: 600,
      imageQuality: 85,
    );
    setState(() {
      _images.addAll(pickedFiles.map((file) => File(file.path)));
    });
  }

  Future<void> _uploadAllData() async {
    setState(() {
      _isUploading = true;
    });

    try {
      if (_formKey.currentState!.validate() && _images.isNotEmpty) {
        User? firebaseUser = FirebaseAuth.instance.currentUser;

        if (firebaseUser != null) {
          String name = _nameController.text;
          double? price =
              double.tryParse(_priceController.text); // Convert price to int
          String details = _detailsController.text;
          String subDetails = _subDetailsController.text;

          List<String> imageUrl = [];
          double totalProgress = 0.0;

          for (var imageFile in _images) {
            Reference ref = FirebaseStorage.instance.ref().child(
                'food_images/${DateTime.now().millisecondsSinceEpoch}_${_images.indexOf(imageFile)}.jpg');

            UploadTask uploadTask = ref.putFile(imageFile);
            TaskSnapshot snapshot = await uploadTask;
            String imageURL = await snapshot.ref.getDownloadURL();
            imageUrl.add(imageURL);

            totalProgress += 1 / _images.length;
            setState(() {
              _uploadProgress = totalProgress;
            });
          }

          await FirebaseFirestore.instance.collection("menu").add({
            "name": name,
            "price": price, // Ensure price is stored as int
            "details": details,
            "subDetails": subDetails,
            "category": category,
            "userId": firebaseUser.uid,
            "isFav": false,
            "imageUrl": imageUrl[0],
            "moreImagesUrl": imageUrl,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(
                    Icons.notifications_active_outlined,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Menu Created",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: kPrimaryColor,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 6,
            ),
          );
          Navigator.pop(context);

          print("Data upload successful.");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(
                    Icons.nearby_error,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Error found",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 6,
            ),
          );

          print("User is null. Unable to upload data.");
        }
      }
    } catch (e) {
      print("Error uploading user data: $e");
    } finally {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kTextWhiteColor,
        centerTitle: true,
        title: const Text(
          'Create Menu',
          style: TextStyle(color: Colors.green),
        ),
      ),
      drawer: AdminDrawer(),
      body: _isUploading
          ? Center(
              child: CircularPercentIndicator(
                radius: 80.0,
                lineWidth: 16.0,
                percent: _uploadProgress,
                center: Text('${(_uploadProgress * 100).toStringAsFixed(0)}%'),
                progressColor: Colors.blue,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInputField(_nameController, 'Food Name'),
                    const SizedBox(height: 16.0),
                    _buildInputField(_priceController, 'Price'),
                    const SizedBox(height: 16.0),
                    _buildInputField(_detailsController, 'Details',
                        maxLines: 5),
                    const SizedBox(height: 16.0),
                    _buildInputField(_subDetailsController, 'Sub - Details'),
                    const SizedBox(height: 16.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        hint: Text('Category',
                            style: TextStyle(color: Colors.black)),
                        value: category,
                        onChanged: (newValue) {
                          setState(() {
                            category = newValue!;
                          });
                        },
                        validator: (val) =>
                            val!.isEmpty ? 'Select Category' : null,
                        items: <String>[
                          '',
                          'Vegetables',
                          'Fruits',
                          'Dairy',
                          'Proteins',
                          'Grains',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Text(
                                value,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w300),
                              ),
                            ),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: InputBorder
                              .none, // Remove the border of the DropdownButtonFormField
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            width: MediaQuery.of(context).size.width/1.28,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.green[300]
                            ),
                            child: TextButton(
                                onPressed: _uploadAllData,
                                child: Text(
                                  'Add new product',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                          ),
                        ),
                        IconButton(
                            onPressed: _getImage,
                            icon: Icon(
                              Icons.image,
                              color: Colors.green[300],
                            )),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    _images.isEmpty
                        ? Container()
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: _images.length,
                            itemBuilder: (context, index) {
                              return Image.file(
                                _images[index],
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String labelText,
      {int maxLines = 1, TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $labelText';
          }
          if (labelText == 'Price' && double.tryParse(value) == null) {
            return 'Please enter a valid double price';
          }
          return null;
        },
      ),
    );
  }
}
