import 'package:date_format_field/date_format_field.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/Screens/auth/register/signupForm/user_form_view_model.dart';
import 'package:health_chain/utils/colors.dart';
import 'package:provider/provider.dart';

import '../../../../utils/themes.dart';
import '../../../../widgets/appBar.dart';
import '../../../../widgets/button.dart';
import '../../../../widgets/textField.dart';

class UserFormView extends StatelessWidget {
  const UserFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final userFormViewModel = Provider.of<UserFormViewModel>(context);
    
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                            'Complete Your Profile',
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Tell us more about yourself',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 40.h),
                    
                    // Form Container
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
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Full Name Field
                            OutlineBorderTextFormField(
                              labelText: "Full Name",
                              obscureText: false,
                              tempTextEditingController: userFormViewModel.nomController,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              validation: (textToValidate) {
                                return userFormViewModel.getTempAccountValidationname(textToValidate);
                              },
                              mySuffixIcon: null,
                            ),
                            SizedBox(height: 16.h),
                            
                            // Phone Number Field
                            OutlineBorderTextFormField(
                              labelText: "Phone Number",
                              obscureText: false,
                              tempTextEditingController: userFormViewModel.telController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              validation: (textToValidate) {
                                return userFormViewModel.getTempAccountValidationtel(textToValidate);
                              },
                              mySuffixIcon: null,
                            ),
                            SizedBox(height: 16.h),
                            
                            // Password Field
                            OutlineBorderTextFormField(
                              labelText: "Password",
                              obscureText: userFormViewModel.isPassVisible,
                              tempTextEditingController: userFormViewModel.mdpController,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              validation: (textToValidate) {
                                return userFormViewModel.getTempAccountValidationmdp(textToValidate);
                              },
                              mySuffixIcon: Container(
                                child: InkWell(
                                  onTap: userFormViewModel.togglePasswordVisibility,
                                  child: Icon(
                                    userFormViewModel.isPassVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                            
                            // Password Requirements
                            Padding(
                              padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
                              child: Text(
                                'Password must contain at least 8 characters, including uppercase, number and special character',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            
                            // Date of Birth Field
                            Text(
                              'Date of Birth',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            DateFormatField(
                              type: DateFormatType.type4,
                              addCalendar: true,
                              controller: userFormViewModel.dateController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                              ),
                              onComplete: (date) {
                                userFormViewModel.date = date;
                              },
                            ),
                            SizedBox(height: 24.h),
                            
                            // Gender Selection
                            Text(
                              'Gender',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => userFormViewModel.selectGender("male"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: userFormViewModel.masculinColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                      padding: EdgeInsets.symmetric(vertical: 12.h),
                                    ),
                                    child: Text(
                                      'Male',
                                      style: TextStyle(
                                        color: userFormViewModel.selectedGender == "male"
                                            ? Colors.white
                                            : Colors.black87,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => userFormViewModel.selectGender("female"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: userFormViewModel.femininColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                      padding: EdgeInsets.symmetric(vertical: 12.h),
                                    ),
                                    child: Text(
                                      'Female',
                                      style: TextStyle(
                                        color: userFormViewModel.selectedGender == "female"
                                            ? Colors.white
                                            : Colors.black87,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 32.h),
                            
                            // Continue Button
                            SizedBox(
                              width: double.infinity,
                              height: 50.h,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    Navigator.pushNamed(context, '/profile_img_view');
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
