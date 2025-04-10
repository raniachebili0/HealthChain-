import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/colors.dart';

class ErrorAlert extends StatefulWidget {
  final String errorText;

  const ErrorAlert({Key? key, required this.errorText, required String message})
      : super(key: key);

  @override
  State<ErrorAlert> createState() => _ErrorAlertState();
}

class _ErrorAlertState extends State<ErrorAlert> {
  void buttonAction() async {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(5.0), // Adjust the BorderRadius as needed
      ),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Image.asset(
                  "assets/icons/close2.png",
                  height: 24.h,
                  width: 24.w,
                ),
              ),
            ],
          ),
          Image.asset(
            "assets/icons/notificationError.png",
            height: 53.h,
            width: 53.w,
          ),
          SizedBox(
            height: 19.h,
          ),
          Text("Il y a eu un problème",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              )),
          SizedBox(
            height: 17.h,
          ),
          Text(
            widget.errorText,
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Color(0xff000000).withOpacity(0.7)),
          ),
          SizedBox(
            height: 29.h,
          ),
          InkWell(
            onTap: () {
              buttonAction();
            },
            child: Container(
              //margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 0*fem, 0*fem),
              width: double.infinity,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7.r),
                gradient: LinearGradient(
                  begin: Alignment(-1, 0.019),
                  end: Alignment(1, 0.019),
                  colors: <Color>[
                    Color(0xFFF26956),
                    Color(0xFFFF6D00),
                  ],
                  stops: <double>[0, 1],
                ),
              ),
              child: Center(
                child: Text(
                  "Réessayez",
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.2575.sign,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
