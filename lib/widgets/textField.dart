import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/colors.dart';

class OutlineBorderTextFormField extends StatefulWidget {
  TextEditingController tempTextEditingController;
  String? labelText;
  TextInputType keyboardType;
  TextInputAction textInputAction;
  Function validation;
  Container? mySuffixIcon;
  bool obscureText;

  @override
  State<StatefulWidget> createState() {
    return _OutlineBorderTextFormField();
  }

  OutlineBorderTextFormField({
    super.key,
    this.labelText,
    required this.mySuffixIcon,
    required this.obscureText,
    required this.tempTextEditingController,
    required this.keyboardType,
    required this.textInputAction,
    required this.validation,
  });
}

class _OutlineBorderTextFormField extends State<OutlineBorderTextFormField> {
  bool isError = false;
  String errorString = "";

  getLabelTextStyle() {
    return TextStyle(
      fontFamily: 'Inter',
      color: AppColors.textInputColor,
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
    );
  } //label text styl

  getTextFieldStyle() {
    return TextStyle(
      fontFamily: 'Inter',
      color: Colors.black,
      fontSize: 15.sp,
      fontWeight: FontWeight.w500,
    );
  } //textfield style

  getErrorTextFieldStyle() {
    return TextStyle(
      fontFamily: 'Inter',
      color: AppColors.errorColor,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );
  } // Error text style

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(bottom: 5, left: 5, right: 5),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(30.r)),
              border: Border.all(
                  width: 1,
                  style: BorderStyle.solid,
                  color: isError ? Color(0xFFD00032) : Color(0xFFD9DBDC))),
          child: TextFormField(
            maxLines: 1,
            obscureText: widget.obscureText,
            controller: widget.tempTextEditingController,
            style: getTextFieldStyle(),
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            inputFormatters: [LengthLimitingTextInputFormatter(20)],
            validator: (string) {
              if (widget
                  .validation(widget.tempTextEditingController.text)
                  .toString()
                  .isNotEmpty) {
                setState(() {
                  isError = true;
                  errorString =
                      widget.validation(widget.tempTextEditingController.text);
                });
                return "";
              } else {
                setState(() {
                  isError = false;
                  errorString =
                      widget.validation(widget.tempTextEditingController.text);
                });
              }
              return null;
            },
            decoration: InputDecoration(
                labelText: widget.labelText,
                floatingLabelBehavior: FloatingLabelBehavior.never,
                labelStyle: getLabelTextStyle(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 7, horizontal: 16),
                //  fillColor: Colors.lightBlue,
                filled: false,
                suffixIcon: Align(
                  widthFactor: 1.0,
                  heightFactor: 1.0,
                  child: widget.mySuffixIcon,
                ),
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                border: InputBorder.none,
                errorStyle: TextStyle(height: 0),
                focusedErrorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none),
          ),
        ),
        Visibility(
            visible: isError ? true : false,
            child: Container(
                padding: EdgeInsets.only(left: 15.0, top: 2.0),
                child: Text(
                  errorString,
                  style: getErrorTextFieldStyle(),
                ))),
      ],
    );
  }
}

class OutlineBorderTextFormFieldExp extends StatefulWidget {
  FocusNode myFocusNode;
  TextEditingController tempTextEditingController;
  String labelText;
  TextInputType keyboardType;
  bool autofocus = false;
  TextInputAction textInputAction;
  List<TextInputFormatter> inputFormatters;
  Function validation;
  Container? mySuffixIcon;
  Container? myPrefixIcon;
  bool checkOfErrorOnFocusChange =
      false; //If true validation is checked when evre focus is changed
  bool obscureText;

  @override
  State<StatefulWidget> createState() {
    return _OutlineBorderTextFormFieldExp();
  }

  OutlineBorderTextFormFieldExp(
      {super.key,
      required this.labelText,
      required this.mySuffixIcon,
      required this.myPrefixIcon,
      required this.obscureText,
      required this.autofocus,
      required this.tempTextEditingController,
      required this.myFocusNode,
      required this.inputFormatters,
      required this.keyboardType,
      required this.textInputAction,
      required this.validation,
      required this.checkOfErrorOnFocusChange});
}

class _OutlineBorderTextFormFieldExp
    extends State<OutlineBorderTextFormFieldExp> {
  bool isError = false;
  String errorString = "";

  getLabelTextStyle(color) {
    return TextStyle(
      fontFamily: 'Inter',
      color: AppColors.textInputColor,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    );
  } //label text style

  getTextFieldStyle() {
    return TextStyle(
      fontFamily: 'Inter',
      color: Colors.black,
      fontSize: 15,
      fontWeight: FontWeight.w500,
    );
  } //textfield style

  getErrorTextFieldStyle() {
    return TextStyle(
      fontFamily: 'Inter',
      color: AppColors.errorColor,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );
  } // Error text style

  getBorderColor(isfous) {
    return isfous ? Color(0xFFD9DBDC) : Color(0xFFD9DBDC);
  } //Border colors according to focus

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FocusScope(
            child: Focus(
              onFocusChange: (focus) {
                //Called when ever focus changes
                // print("focus: $focus");
                setState(() {
                  getBorderColor(focus);
                  if (widget.checkOfErrorOnFocusChange &&
                      widget
                          .validation(widget.tempTextEditingController.text)
                          .toString()
                          .isNotEmpty) {
                    isError = true;
                    errorString = widget
                        .validation(widget.tempTextEditingController.text);
                  } else {
                    isError = false;
                    errorString = widget
                        .validation(widget.tempTextEditingController.text);
                  }
                });
              },
              child: Container(
                padding: EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(8.r)),
                    border: Border.all(
                      width: 1,
                      style: BorderStyle.solid,
                      color: isError
                          ? Color(0xFFD00032)
                          : getBorderColor(widget.myFocusNode.hasFocus),
                    )),
                child: TextFormField(
                  maxLines: 1,
                  obscureText: widget.obscureText,
                  focusNode: widget.myFocusNode,
                  controller: widget.tempTextEditingController,
                  style: getTextFieldStyle(),
                  autofocus: widget.autofocus,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  inputFormatters: widget.inputFormatters,
                  validator: (string) {
                    if (widget
                        .validation(widget.tempTextEditingController.text)
                        .toString()
                        .isNotEmpty) {
                      setState(() {
                        isError = true;
                        errorString = widget
                            .validation(widget.tempTextEditingController.text);
                      });
                      return "";
                    } else {
                      setState(() {
                        isError = false;
                        errorString = widget
                            .validation(widget.tempTextEditingController.text);
                      });
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      labelText: widget.labelText,
                      labelStyle: isError
                          ? getLabelTextStyle(Color(0xFFD00032))
                          : getLabelTextStyle(Color(0xFFD9DBDC)),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 7, horizontal: 16),
                      fillColor: Colors.white,
                      filled: true,
                      suffixIcon: Align(
                        widthFactor: 1.0,
                        heightFactor: 1.0,
                        child: widget.mySuffixIcon,
                      ),
                      prefixIcon: Align(
                        widthFactor: 1.0,
                        heightFactor: 1.0,
                        child: widget.myPrefixIcon,
                      ),
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      border: InputBorder.none,
                      errorStyle: TextStyle(height: 0),
                      focusedErrorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      floatingLabelBehavior: FloatingLabelBehavior.auto),
                ),
              ),
            ),
          ),
          Visibility(
              visible: isError ? true : false,
              child: Container(
                  padding: EdgeInsets.only(left: 15.0, top: 2.0),
                  child: Text(
                    errorString,
                    style: getErrorTextFieldStyle(),
                  ))),
        ],
      ),
    );
  }
}
