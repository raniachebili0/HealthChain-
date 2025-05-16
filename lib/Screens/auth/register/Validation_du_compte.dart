import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/Screens/auth/register/inscriptionScreen/inscription_view_model.dart';
import 'package:health_chain/Screens/auth/register/validation_view_model.dart';
import 'package:health_chain/routes/app_router.dart';
import 'package:health_chain/services/auth_service.dart';
import 'package:provider/provider.dart';
import '../../../../models/SharedData.dart';
import '../../../utils/colors.dart';
import '../../../utils/themes.dart';
import '../../../widgets/appBar.dart';
import '../../../widgets/errorAlert.dart';
import '../../../widgets/button.dart';
import 'package:http/http.dart' as http;

class ValidationDuCompte extends StatelessWidget {
  const ValidationDuCompte({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inscriptionViewModel = Provider.of<InscriptionViewModel>(context);
    final sharedData = Provider.of<SharedData>(context, listen: false);
    final validationViewModel = Provider.of<ValidationViewModel>(context);

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
                          Container(
                            width: 80.w,
                            height: 80.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(20.w),
                            child: Icon(
                              Icons.mark_email_read_outlined,
                              size: 32.w,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            'Verify Your Email',
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Enter the code sent to your email',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 40.h),
                    
                    // OTP Form Container
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enter OTP',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          
                          // OTP Input Field
                          OtpTextField(
                            fieldWidth: 35.w,
                            fieldHeight: 50.h,
                            numberOfFields: 6,
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            enabledBorderColor: validationViewModel.hasError
                                ? AppColors.errorColor
                                : Colors.grey[300]!,
                            focusedBorderColor: validationViewModel.hasError
                                ? AppColors.errorColor
                                : AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(12.r),
                            keyboardType: TextInputType.number,
                            borderWidth: 1.5,
                            textStyle: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                            showFieldAsBox: true,
                            onCodeChanged: (String code) {},
                            onSubmit: (String code) {
                              validationViewModel.setVerificationCode(code);
                            },
                          ),
                          
                          SizedBox(height: 16.h),
                          
                          // Resend Code Link
                          Center(
                            child: TextButton(
                              onPressed: () => validationViewModel.resendOtp(
                                inscriptionViewModel.emailController.text,
                              ),
                              child: Text(
                                "Didn't receive the code?",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 32.h),
                          
                          // Verify Button
                          SizedBox(
                            width: double.infinity,
                            height: 50.h,
                            child: ElevatedButton(
                              onPressed: () {
                                final validationMessage = validationViewModel
                                    .validateVerificationCode(
                                        validationViewModel.verificationCode);

                                if (validationMessage != "valide") {
                                  validationViewModel.setError(true);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(validationMessage),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                } else {
                                  validationViewModel.setError(false);
                                  validationViewModel.verifyOtp(
                                    context,
                                    inscriptionViewModel.emailController.text,
                                    validationViewModel.verificationCode,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Verify',
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
