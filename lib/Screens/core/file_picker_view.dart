import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:health_chain/routes/app_router.dart';
import 'package:health_chain/utils/themes.dart';
import 'package:pdfx/pdfx.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:health_chain/services/user_service.dart';
import 'package:health_chain/widgets/appBar.dart';
import 'package:health_chain/widgets/button.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class FilePickerScreen extends StatefulWidget {
  final String category;

  const FilePickerScreen({super.key, required this.category});

  @override
  _FilePickerScreenState createState() => _FilePickerScreenState();
}

class _FilePickerScreenState extends State<FilePickerScreen> {
  String? pdfPath;
  PdfController? pdfController;
  final String baseUrl = 'http://10.0.2.2:3000/medical-records';
  final storage = FlutterSecureStorage();

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'], // Only allow PDFs
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

  Future<String?> getAuthToken() async {
    return await storage.read(key: "auth_token");
  }

  Future<Map<String, dynamic>> uploadFile(File file, String fileType) async {
    try {
      String? authToken = await getAuthToken();
      if (authToken == null) throw Exception("Authentication token is missing");

      var uri = Uri.parse('$baseUrl/upload');
      var request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $authToken'
        ..fields['fileType'] = fileType
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path,
            contentType: MediaType.parse(
                lookupMimeType(file.path) ?? 'application/octet-stream'),
          ),
        );

      var response = await request.send();
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseBody = await response.stream.bytesToString();
        return json.decode(responseBody);
      } else {
        throw Exception('Failed to upload file');
      }
    } catch (e) {
      throw Exception('Error uploading file: $e');
    }
  }

  void buttonAction(BuildContext context, String? pdfPath) async {
    if (pdfPath != null && File(pdfPath).existsSync()) {
      try {
        await uploadFile(File(pdfPath), widget.category);

        // Show success alert dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Success"),
              content: Text("File uploaded successfully!"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the alert dialog
                    Navigator.pushReplacementNamed(context,
                        AppRoutes.documentScreen); // Navigate to DocumentScreen
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      } catch (e) {
        print("Error: $e");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload file')),
        );
      }
    } else {
      print("No file selected or invalid path");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a valid file')),
      );
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
                      'Hi patient, Add your document',
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
