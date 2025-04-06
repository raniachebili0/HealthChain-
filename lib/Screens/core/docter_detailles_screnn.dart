import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/Screens/core/CreateAppointmentScreen.dart';
import 'package:health_chain/utils/colors.dart';
import 'package:health_chain/widgets/appBar.dart';

class DoctorDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> doctor;

  const DoctorDetailsScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const CustomAppBar(appbartext: 'Doctor Profile'),
                  Container(
                    padding: EdgeInsets.only(bottom: 10),
                    width: double.infinity,
                    // height: 220.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(
                            height: 150.h,
                            width: 150.w,
                            child: Hero(
                              tag: doctor['photo'],
                              child: doctor['photo'] != null &&
                                      doctor['photo'].startsWith("http")
                                  ? Image.network(
                                      doctor['photo'],
                                      // width: 100,
                                      // height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
                                              Icons.person,
                                              size: 50,
                                              color: Colors.grey.shade400),
                                    )
                                  : Image.asset(
                                      'assets/images/Landing.png',
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                            )),
                        SizedBox(height: 8.h),
                        Text(
                          "Dr. ${doctor['name']}" ?? "User Name",
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.email, size: 18, color: Colors.black45),
                            SizedBox(width: 5),
                            Text(
                              doctor['email'] ?? "User Email",
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black45),
                            ),
                            SizedBox(width: 15),
                            Icon(Icons.phone, size: 18, color: Colors.black45),
                            SizedBox(width: 5),
                            Text(
                              doctor['telecom'] ?? "User Tel",
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black45),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildInfoCard(
                      "Bio", doctor['doctorbio'] ?? "No bio available"),
                  _buildInfoCard(
                      "Address", doctor['address'] ?? "No address available"),
                  _buildInfoCard("Schedules",
                      doctor['doctorhoraire'] ?? "No schedules available"),
                  SizedBox(
                    height: 60.h,
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateAppointmentScreen(
                                  doctorId: doctor['_id'])),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: EdgeInsets.symmetric(
                            horizontal: 60.h, vertical: 17.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Book Appointment',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black45),
          ),
          SizedBox(height: 5.h),
          Text(
            content,
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black45),
          ),
        ],
      ),
    );
  }
}
