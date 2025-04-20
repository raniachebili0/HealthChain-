import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

/// This widget is only used on web platforms
Widget getImagePreviewWidget({
  required XFile? pickedImage,
  required Uint8List? webImageBytes,
  required bool isWeb,
}) {
  if (webImageBytes != null) {
    return Image.memory(
      webImageBytes,
      height: 300,
      width: double.infinity,
      fit: BoxFit.cover,
    );
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