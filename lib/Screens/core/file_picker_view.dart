import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'dart:io';

import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/routes/app_router.dart';
import 'package:health_chain/utils/themes.dart';
import 'package:health_chain/widgets/appBar.dart';
import 'package:health_chain/widgets/button.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdfx/pdfx.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(appbartext: 'Sign Up'),
            Padding(
              padding: EdgeInsets.fromLTRB(17.w, 0.h, 17.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 13.h),
                    child: Text(
                      'Hi doctor ,Verify your identity',
                      style: CustomTextStyle.titleStyle,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 28.h),
                    child: Text(
                      'Please submit a document that verifies your position',
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
                                    // Optional, for rounded corners
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        // Shadow color
                                        offset: Offset(0, 4),
                                        // Horizontal and vertical offset
                                        blurRadius: 6,
                                        // Blur radius of the shadow
                                        spreadRadius:
                                            1, // How much the shadow spreads
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                      child: IconButton(
                                    onPressed: pickFile,
                                    icon: Icon(Icons.file_open_rounded),
                                    tooltip: "Pick Image",
                                    iconSize: 70,
                                  )),
                                ),
                        ),
                        SizedBox(height: 120.h),
                        MyButton(
                            buttonFunction: () => null,
                            //Navigator.pushNamed(
                            //     context, AppRoutes.validationDuCompte),
                            buttonText: 'Sign Up'),
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
