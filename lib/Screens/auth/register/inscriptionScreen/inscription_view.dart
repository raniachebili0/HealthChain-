import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/routes/app_router.dart';
import 'package:health_chain/utils/themes.dart';
import 'package:health_chain/widgets/button.dart';
import 'package:provider/provider.dart';
import '../../../../../widgets/appBar.dart';
import '../../../../../widgets/textField.dart';
import 'inscription_view_model.dart';
import '../../../../../utils/colors.dart';

@RoutePage()
class InscriptionScreen extends StatelessWidget {
  const InscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inscriptionViewModel = Provider.of<InscriptionViewModel>(context);
    final GlobalKey<FormState> formKeyinscr = GlobalKey<FormState>();
    
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
                    
                    // Logo and Welcome Section
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 120.w,
                            height: 120.w,
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
                            child: Image.asset('assets/logo/logo.png'),
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Join HealthChain today',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 40.h),
                    
                    // Registration Form
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
                      child: Form(
                        key: formKeyinscr,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            
                            // Email Field
                            OutlineBorderTextFormField(
                              labelText: "Email",
                              obscureText: false,
                              tempTextEditingController: inscriptionViewModel.emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              validation: inscriptionViewModel.validateEmail,
                              mySuffixIcon: inscriptionViewModel.valide
                                  ? Container(
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 20.w,
                                      ),
                                    )
                                  : null,
                            ),
                            
                            SizedBox(height: 24.h),
                            
                            // Sign Up Button
                            SizedBox(
                              width: double.infinity,
                              height: 50.h,
                              child: ElevatedButton(
                                onPressed: () => inscriptionViewModel.buttonAction(context, formKeyinscr),
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
                            
                            SizedBox(height: 24.h),
                            
                            // Login Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Already have an account? ",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(context, '/login_view'),
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
