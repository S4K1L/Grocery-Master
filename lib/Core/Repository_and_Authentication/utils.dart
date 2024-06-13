import 'package:flutter/services.dart';

class Utils {
  static Future<Uint8List> loadImageFromUrl(String imageUrl) async {
    try {
      final response = await NetworkAssetBundle(Uri.parse(imageUrl)).load('');
      return response.buffer.asUint8List();
    } catch (e) {
      print('Error loading image from URL: $e');
      return Uint8List(0); // Return a default image
    }
  }
}