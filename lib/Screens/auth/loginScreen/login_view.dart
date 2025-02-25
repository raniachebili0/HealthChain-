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
          Opacity(
            opacity: 0.9,
            child: Image.asset(
              'assets/imeges/bg.jpg',
              // Make sure the image is in assets folder
              fit: BoxFit.cover, // Ensures the image covers the entire screen
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 150.h,
                    child: Image.asset('assets/logo/logo.png'),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 13.h),
                    child: Text(
                      'Welcome back to HealthChain',
                      style: CustomTextStyle.titleStyle,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 28.h),
                    child: Text(
                      'Please enter your email and password to login.',
                      style: CustomTextStyle.h2,
                    ),
                  ),
                  Form(
                    key: formKeylogin,
                    child: Expanded(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: OutlineBorderTextFormField(
                              labelText: "Email",
                              obscureText: false,
                              tempTextEditingController:
                                  loginViewModel.emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validation: loginViewModel.validateEmail,
                              mySuffixIcon: null,
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: OutlineBorderTextFormField(
                              labelText: "Password",
                              obscureText: loginViewModel.isPassVisible,
                              tempTextEditingController:
                                  loginViewModel.passwordController,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              validation: loginViewModel.validatePassword,
                              mySuffixIcon: Container(
                                child: InkWell(
                                  onTap:
                                      loginViewModel.togglePasswordVisibility,
                                  child: Image.asset(
                                    loginViewModel.isPassVisible
                                        ? 'assets/icons/vector.png'
                                        : 'assets/icons/union.png',
                                    height: 20,
                                    width: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () =>
                                  Navigator.pushNamed(context, '/RestMDP'),
                              child: Text(
                                'Forgot your password?',
                                style: CustomTextStyle.h4
                                    .copyWith(fontSize: 12.sp),
                              ),
                            ),
                          ),
                          Spacer(),
                          // SizedBox(height: 37.h),
                          MyButton(
                            buttonFunction: () {
                              print("Button clicked");
                              loginViewModel.buttonAction(
                                  context, formKeylogin);
                            },
                            buttonText: 'Login',
                          ),

                          SizedBox(height: 13.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("I don't have an account. ",
                                  style: CustomTextStyle.h4),
                              InkWell(
                                onTap: () => Navigator.pushNamed(
                                    context, AppRoutes.inscription),
                                child: Text('Sign up ',
                                    style: CustomTextStyle.lien),
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
        ],
      ),
    );
  }
}
