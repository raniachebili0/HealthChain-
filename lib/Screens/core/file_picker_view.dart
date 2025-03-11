import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/utils/themes.dart';
import 'package:pdfx/pdfx.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:health_chain/services/user_service.dart';
import 'package:health_chain/widgets/appBar.dart';
import 'package:health_chain/widgets/button.dart';

class FilePickerScreen extends StatefulWidget {
  @override
  _FilePickerScreenState createState() => _FilePickerScreenState();
}

class _FilePickerScreenState extends State<FilePickerScreen> {
  String? pdfPath;
  PdfController? pdfController;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // Only allow PDFs
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        pdfPath = result.files.single.path!;
        pdfController = PdfController(document: PdfDocument.openFile(pdfPath!));
      });
    } else {
      print("No file selected");
    }
  }

  Future<void> uploadFile(File? filePath) async {
    if (filePath == null) return;

    final uri = Uri.parse(
        'http://10.0.2.2:3000/files/upload'); // Change to your server URL
    var request = http.MultipartRequest('POST', uri);

    var pic = await http.MultipartFile.fromPath(
      'file',
      filePath.path,
    );
    request.files.add(pic);

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        print('File uploaded successfully');
        // Handle successful response here
      } else {
        print('Failed to upload file');
        // Handle failure here
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  void buttonAction(BuildContext context, String? pdfPath) async {
    if (pdfPath != null && File(pdfPath).existsSync()) {
      final userService = Provider.of<UserService>(context, listen: false);

      // Call the uploadFile method with the file
      await uploadFile(File(pdfPath));
    } else {
      print("No file selected or invalid path");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(appbartext: 'Upload File'),
            Padding(
              padding: EdgeInsets.fromLTRB(17.0, 0.0, 17.0, 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 13.h),
                    child: Text(
                      'Hi patient ,Add your document',
                      style: CustomTextStyle.titleStyle,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 28.h),
                    child: Text(
                      "Securely upload and manage your medical records for easy access anytime.",
                      style: CustomTextStyle.h2,
                    ),
                  ),
                  Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 300,
                          child: pdfPath != null && File(pdfPath!).existsSync()
                              ? PdfView(controller: pdfController!)
                              : Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white30,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        offset: Offset(0, 4),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: IconButton(
                                      onPressed: pickFile,
                                      icon: Icon(Icons.file_open_rounded),
                                      tooltip: "Pick PDF",
                                      iconSize: 70,
                                    ),
                                  ),
                                ),
                        ),
                        SizedBox(height: 120),
                        MyButton(
                          buttonFunction: () => buttonAction(context, pdfPath),
                          buttonText: 'Upload',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
