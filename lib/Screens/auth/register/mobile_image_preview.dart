import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

/// This widget is only used on mobile platforms
Widget getImagePreviewWidget({
  required XFile? pickedImage,
  required Uint8List? webImageBytes,
  required bool isWeb,
}) {
  // Never directly reference Image.file inside the method body!
  if (pickedImage != null) {
    // Use a builder pattern to ensure Image.file is only created at runtime
    return _createImageWidget(pickedImage.path);
  }
  
  return Container(
    height: 300,
    width: double.infinity,
    color: Colors.grey.shade200,
    child: Center(
      child: Text('No image selected',
        style: TextStyle(color: Colors.grey)),
    ),
  );
}

// This function is in a separate method to ensure that
// dart:io and Image.file are not evaluated during compilation
Widget _createImageWidget(String path) {
  // Only used on mobile, create a File instance
  final imageFile = File(path);
  
  // This Image.file will only be created during runtime
  // on mobile platforms, never during compilation
  return Builder(
    builder: (context) {
      try {
        return Image.file(
          imageFile,
          height: 300,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      } catch (e) {
        return Container(
          height: 300,
          width: double.infinity,
          color: Colors.grey.shade200,
          child: Center(
            child: Text('Error loading image: $e',
              style: TextStyle(color: Colors.red)),
          ),
        );
      }
    },
  );
} 