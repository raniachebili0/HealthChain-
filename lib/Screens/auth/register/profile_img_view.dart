import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/Screens/auth/register/signupForm/doctor_form_view_model.dart';
import 'package:health_chain/Screens/auth/register/signupForm/user_form_view_model.dart';
import 'package:health_chain/routes/app_router.dart';
import 'package:health_chain/services/auth_service.dart';
import 'package:health_chain/utils/colors.dart';
import 'package:health_chain/utils/themes.dart';
import 'package:health_chain/widgets/appBar.dart';
import 'package:health_chain/widgets/button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'inscriptionScreen/inscription_view_model.dart';

class ImagePickerScreen extends StatefulWidget {
  @override
  _ImagePickerScreenState createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  File? selectedImage;
  String? imagePath;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
        selectedImage = File(pickedFile.path);
      });
    }
  }

  void buttonAction(BuildContext context, email, gender, nom, mdp, date, tel) async {
    final _authService = Provider.of<AuthService>(context, listen: false);

    String signupResult = await _authService.signup(
        email: email,
        name: nom,
        tel: tel,
        password: mdp,
        birthDate: date,
        gender: gender,
        filePath: selectedImage);

    if (signupResult.contains("success")) {
      print("Signup successful!");
      // Navigate to the next screen
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } else {
      print("Signup failed: $signupResult");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Signup failed: $signupResult")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final inscriptionViewModel = Provider.of<InscriptionViewModel>(context);
    final userFormViewModel = Provider.of<UserFormViewModel>(context);
    final doctorFormViewModel = Provider.of<DoctorFormViewModel>(context);
    String email = inscriptionViewModel.emailController.text;
    String Gender = userFormViewModel.selectedGender;
    String Name = userFormViewModel.nomController.text;
    String Password = userFormViewModel.mdpController.text;
    String BirthDate =
        userFormViewModel.date.toString();
    String Tel = userFormViewModel.telController.text;
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
                          child: selectedImage != null
                              ? Image.file(
                                  selectedImage!,
                                  height: 300,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : _buildPlaceholder(),
                        ),
                        SizedBox(height: 80.h),
                        MyButton(
                            buttonFunction: () => buttonAction(
                                context,
                                email,
                                Gender,
                                Name,
                                Password,
                                BirthDate,
                                Tel),
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
  
  Widget _buildPlaceholder() {
    return Container(
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
          onPressed: _pickImage,
          icon: Icon(Icons.add_a_photo),
          tooltip: "Pick Image",
          iconSize: 70,
        ),
      ),
    );
  }
}
