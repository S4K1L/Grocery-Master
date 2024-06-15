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

  List<File> _images = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;

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
          int? price = int.tryParse(_priceController.text); // Convert price to int
          String details = _detailsController.text;

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
          'Create Manu',
          style: TextStyle(color: Colors.red),
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
              _buildInputField(_detailsController, 'Details'),
              const SizedBox(height: 16.0),
              SizedBox(
                height: 50,
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: () {
                    _getImage();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7F39FB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Select Images',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              _images.isEmpty
                  ? Container()
                  : Column(
                children: _images.map((image) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.file(
                      image,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                height: 50,
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: () {
                    _uploadAllData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7F39FB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Create',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String labelText,
      {TextInputType? keyboardType}) {
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
          if (labelText == 'Price' && int.tryParse(value) == null) {
            return 'Please enter a valid integer price';
          }
          return null;
        },
      ),
    );
  }
}
