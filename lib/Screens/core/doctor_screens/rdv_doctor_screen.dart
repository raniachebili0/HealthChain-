import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/utils/colors.dart';

class RdvDoctorScreen extends StatefulWidget {
  const RdvDoctorScreen({super.key});

  @override
  State<RdvDoctorScreen> createState() => _RdvDoctorScreenState();
}

class _RdvDoctorScreenState extends State<RdvDoctorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Appointments',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_rounded),
            color: Colors.grey[700],
            onPressed: () {
              Navigator.pushNamed(context, '/notification_screen');
            },
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: const Center(
        child: Text('Doctor Appointments Screen'),
      ),
    );
  }
}
