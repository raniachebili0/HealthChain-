import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/colors.dart';
import '../utils/themes.dart';

class MyButton extends StatefulWidget {
  final Function buttonFunction;
  final String buttonText;

  const MyButton(
      {super.key, required this.buttonFunction, required this.buttonText});

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.buttonFunction();
      },
      child: Container(
        //margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 0*fem, 0*fem),
        width: double.infinity,
        height: 53.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.r),
          gradient: LinearGradient(
            begin: Alignment(-1, 0.019),
            end: Alignment(1, 0.019),
            colors: <Color>[AppColors.secondaryColor, AppColors.primaryColor],
            stops: <double>[0, 1],
          ),
        ),
        child: Center(
          child: Text(
            widget.buttonText,
            style: CustomTextStyle.buttonText,
          ),
        ),
      ),
    );
  }
}
