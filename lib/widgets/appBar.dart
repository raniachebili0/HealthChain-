import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/themes.dart';

class CustomAppBar extends StatefulWidget {
  final String appbartext;

  const CustomAppBar({Key? key, required this.appbartext}) : super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0.h, 0.h, 0.h, 19.09.h),
      width: double.infinity,
      height: 77.91.h,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            offset: Offset(0, 2),
            blurRadius: 1,
            // spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        //padding: EdgeInsets.fromLTRB(19.h, 29.h, 154.h, 27.91.h),
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xffffffff),
        ),
        child: Center(
          child: Stack(
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(19.w, 0.h, 0.w, 0.h),
                      width: 20.w,
                      height: 20.h,
                      child: Image.asset(
                        'assets/icons/back.png',
                        width: 20.w,
                        height: 20.h,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                // Wrap the Text widget with Expanded
                child: Center(
                  child: Text(
                    widget.appbartext,
                    style: CustomTextStyle.titleStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
