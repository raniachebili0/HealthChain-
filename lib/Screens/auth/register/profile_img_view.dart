import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/routes/app_router.dart';
import 'package:health_chain/utils/colors.dart';
import 'package:health_chain/utils/themes.dart';
import 'package:health_chain/widgets/appBar.dart';
import 'package:health_chain/widgets/button.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerScreen extends StatefulWidget {
  @override
  _ImagePickerScreenState createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  File? _selectedImage;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
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
                      'Add your profile picture',
                      style: CustomTextStyle.titleStyle,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 28.h),
                    child: Text(
                      'Please choose a clear profile picture in PNG or JPG formats',
                      style: CustomTextStyle.h2,
                    ),
                  ),
                  Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 300.h,
                          child: _selectedImage != null
                              ? Stack(
                                  children: [
                                    Image.file(
                                      _selectedImage!,
                                      height: 300, // Adjust size as needed
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ],
                                )
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
                                    onPressed: _pickImage,
                                    icon: Icon(Icons.add_a_photo),
                                    tooltip: "Pick Image",
                                    iconSize: 70,
                                  )),
                                ),
                        ),
                        SizedBox(height: 80.h),
                        MyButton(
                            buttonFunction: () => Navigator.pushNamed(
                                context, AppRoutes.filePickerScreen),
                            buttonText: 'Continue'),
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
