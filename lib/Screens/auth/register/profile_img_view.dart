import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/Screens/auth/register/inscriptionScreen/inscription_view_model.dart';
import 'package:health_chain/Screens/auth/register/profile_img_view_model.dart';
import 'package:health_chain/Screens/auth/register/signupForm/doctor_form_view_model.dart';
import 'package:health_chain/Screens/auth/register/signupForm/user_form_view_model.dart';
import 'package:health_chain/routes/app_router.dart';
import 'package:health_chain/utils/colors.dart';
import 'package:health_chain/utils/themes.dart';
import 'package:health_chain/widgets/button.dart';
import 'package:provider/provider.dart';
import '../../../../../widgets/appBar.dart';

@RoutePage()
class ProfileImgView extends StatelessWidget {
  const ProfileImgView({super.key});

  @override
  Widget build(BuildContext context) {
    final profileImageViewModel = Provider.of<ProfileImageViewModel>(context);
    final inscriptionViewModel = Provider.of<InscriptionViewModel>(context);
    final userFormViewModel = Provider.of<UserFormViewModel>(context);
    final doctorFormViewModel = Provider.of<DoctorFormViewModel>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background with gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade900.withOpacity(0.8),
                  Colors.blue.shade700.withOpacity(0.9),
                ],
              ),
            ),
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/imeges/bg.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back Button
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),

                    SizedBox(height: 20.h),

                    // Header Section
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Add Profile Photo',
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Let others recognize you',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 40.h),

                    // Profile Image Container
                    Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Profile Image
                          Container(
                            width: 200.w,
                            height: 200.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[100],
                              image: profileImageViewModel.selectedImage != null
                                  ? DecorationImage(
                                      image: FileImage(
                                          profileImageViewModel.selectedImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: profileImageViewModel.selectedImage == null
                                ? Icon(
                                    Icons.person_outline,
                                    size: 80.w,
                                    color: Colors.grey[400],
                                  )
                                : null,
                          ),

                          SizedBox(height: 24.h),

                          // Upload Button
                          SizedBox(
                            width: double.infinity,
                            height: 50.h,
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  profileImageViewModel.pickImage(),
                              icon: Icon(Icons.upload_file),
                              label: Text(
                                'Upload Photo',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[100],
                                foregroundColor: Colors.black87,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
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

                          SizedBox(height: 32.h),

                          // Continue Button
                          SizedBox(
                            width: double.infinity,
                            height: 50.h,
                            child: ElevatedButton(
                              onPressed: () => profileImageViewModel.signup(
                                context: context,
                                email:
                                    inscriptionViewModel.emailController.text,
                                gender: userFormViewModel.selectedGender,
                                name: userFormViewModel.nomController.text,
                                password: userFormViewModel.mdpController.text,
                                birthDate: userFormViewModel.date.toString(),
                                tel: userFormViewModel.telController.text,
                                image: profileImageViewModel.selectedImage,
                                doctorId:
                                    doctorFormViewModel.doctorIdController.text,
                                doctorSpeciality: doctorFormViewModel
                                    .doctorspecialiteController.text,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
