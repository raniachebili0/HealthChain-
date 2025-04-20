import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/Screens/auth/register/profile_img_view_model.dart';
import 'package:health_chain/Screens/auth/register/signupForm/doctor_form_view_model.dart';
import 'package:health_chain/Screens/auth/register/signupForm/user_form_view_model.dart';
import 'package:health_chain/services/auth_service.dart';
import 'package:health_chain/utils/colors.dart';
import 'package:health_chain/utils/themes.dart';
import 'package:health_chain/widgets/appBar.dart';
import 'package:health_chain/widgets/button.dart';
import 'package:provider/provider.dart';
import 'inscriptionScreen/inscription_view_model.dart';

class ImagePickerScreen extends StatelessWidget {
  const ImagePickerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inscriptionViewModel = Provider.of<InscriptionViewModel>(context);
    final userFormViewModel = Provider.of<UserFormViewModel>(context);
    final doctorFormViewModel = Provider.of<DoctorFormViewModel>(context);
    final profileImageViewModel = Provider.of<ProfileImageViewModel>(context);

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
                          child: profileImageViewModel.selectedImage != null
                              ? Image.file(
                                  profileImageViewModel.selectedImage!,
                                  height: 300,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white30,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        offset: const Offset(0, 4),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: IconButton(
                                      onPressed: profileImageViewModel.pickImage,
                                      icon: const Icon(Icons.add_a_photo),
                                      tooltip: "Pick Image",
                                      iconSize: 70,
                                    ),
                                  ),
                                ),
                        ),
                        if (profileImageViewModel.errorMessage != null)
                          Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Text(
                              profileImageViewModel.errorMessage!,
                              style: TextStyle(
                                color: AppColors.errorColor,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        SizedBox(height: 80.h),
                        MyButton(
                          buttonFunction: () => profileImageViewModel.signup(
                            context: context,
                            email: inscriptionViewModel.emailController.text,
                            gender: userFormViewModel.selectedGender,
                            name: userFormViewModel.nomController.text,
                            password: userFormViewModel.mdpController.text,
                            birthDate: userFormViewModel.date.toString(),
                            tel: userFormViewModel.telController.text,
                            image: profileImageViewModel.selectedImage,
                            doctorId: doctorFormViewModel.doctorIdController.text,
                            doctorSpeciality:
                                doctorFormViewModel.doctorspecialiteController.text,
                          ),
                          buttonText: 'Continue',
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
