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
      width: double.infinity,
      height: 60.h,
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
        padding: EdgeInsets.only(left: 19),
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xffffffff),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.appbartext,
            style: CustomTextStyle.titleStyle,
          ),
        ),
      ),
    );
  }
}
