import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocerymaster/Presentation/Screens/User_HomePage/manu_model.dart';
import 'package:grocerymaster/Theme/const.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class EditMenuScreen extends StatefulWidget {
  final MenuModel menu;

  const EditMenuScreen({required this.menu, Key? key}) : super(key: key);

  @override
  _EditMenuScreenState createState() => _EditMenuScreenState();
}

class _EditMenuScreenState extends State<EditMenuScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _detailsController;
  late TextEditingController _subDetailsController;
  List<File> _newImages = [];
  List<String> _updatedImages = [];
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.menu.name);
    _priceController = TextEditingController(text: widget.menu.price.toString());
    _detailsController = TextEditingController(text: widget.menu.details);
    _subDetailsController = TextEditingController(text: widget.menu.subDetails);
    _updatedImages = List.from(widget.menu.moreImagesUrl);
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _newImages.add(File(pickedFile.path));
      }
    });
  }

  Future<void> _updateMenu() async {
    double price = double.parse(_priceController.text);
    if (_formKey.currentState!.validate()) {
      _showLoadingDialog();
      List<String> newImageUrls = [];
      for (var image in _newImages) {
        String imageUrl = await _uploadImageToFirebase(image);
        newImageUrls.add(imageUrl);
      }

      List<String> updatedImageUrls = List.from(_updatedImages)
        ..addAll(newImageUrls);

      await FirebaseFirestore.instance
          .collection('menu')
          .doc(widget.menu.docId)
          .update({
        'name': _nameController.text,
        'price': price,
        'details': _detailsController.text,
        'subDetails': _subDetailsController.text,
        'moreImagesUrl': updatedImageUrls,
      });

      Navigator.pop(context); // Close the loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Menu item updated successfully!')),
      );

      Navigator.pop(context); // Go back to the previous screen
    }
  }

  Future<String> _uploadImageToFirebase(File image) async {
    final storageReference = FirebaseStorage.instance
        .ref()
        .child('menu_images/${DateTime.now().millisecondsSinceEpoch}');
    final uploadTask = storageReference.putFile(image);
    final taskSnapshot = await uploadTask.whenComplete(() => null);
    final downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Uploading..."),
            ],
          ),
        );
      },
    );
  }

  void _removeImage(String url) {
    setState(() {
      _updatedImages.remove(url);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.green, size: 18),
        ),
        title: const Text(
          'Edit Menu Item',
          style: TextStyle(color: Colors.green),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _subDetailsController,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter quantity';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _detailsController,
                  decoration: const InputDecoration(
                    labelText: 'Details',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Details';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                  itemCount: _updatedImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Image.network(_updatedImages[index]),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _removeImage(_updatedImages[index]),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                  itemCount: _newImages.length,
                  itemBuilder: (context, index) {
                    return Image.file(_newImages[index]);
                  },
                ),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text(
                    ' Add New Image ',
                    style: TextStyle(color: kTextWhiteColor),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _updateMenu,
                  child: const Text(
                    'Save',
                    style: TextStyle(color: kTextWhiteColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
