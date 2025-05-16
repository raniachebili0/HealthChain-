import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/Screens/auth/loginScreen/login_view_model.dart';
import 'package:health_chain/routes/app_router.dart';
import 'package:health_chain/widgets/button.dart';
import 'package:health_chain/widgets/textField.dart';
import 'package:provider/provider.dart';
import '../../../utils/themes.dart';
import '../../../utils/colors.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loginViewModel = Provider.of<LoginViewModel>(context);
    final GlobalKey<FormState> formKeylogin = GlobalKey<FormState>();
    
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
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Sign in to continue',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 40.h),
                    
                    // Login Form
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
                        key: formKeylogin,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Login',
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
                              tempTextEditingController: loginViewModel.emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validation: loginViewModel.validateEmail,
                              mySuffixIcon: null,
                            ),
                            SizedBox(height: 16.h),
                            
                            // Password Field
                            OutlineBorderTextFormField(
                              labelText: "Password",
                              obscureText: loginViewModel.isPassVisible,
                              tempTextEditingController: loginViewModel.passwordController,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.done,
                              validation: loginViewModel.validatePassword,
                              mySuffixIcon: Container(
                                child: InkWell(
                                  onTap: loginViewModel.togglePasswordVisibility,
                                  child: Icon(
                                    loginViewModel.isPassVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                            
                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => Navigator.pushNamed(context, '/RestMDP'),
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            
                            SizedBox(height: 24.h),
                            
                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 50.h,
                              child: ElevatedButton(
                                onPressed: () {
                                  loginViewModel.buttonAction(context, formKeylogin);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            
                            SizedBox(height: 24.h),
                            
                            // Sign Up Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(context, '/inscription_view'),
                                  child: Text(
                                    'Sign Up',
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
