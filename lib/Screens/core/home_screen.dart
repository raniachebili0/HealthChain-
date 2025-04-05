import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/Screens/core/docter_detailles_screnn.dart';
import 'package:health_chain/routes/app_router.dart';
import 'package:health_chain/services/user_service.dart';
import 'package:health_chain/utils/colors.dart';
import 'package:health_chain/widgets/doctor_item.dart';

import '../../models/doctor_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final UserService userService = UserService();
    return Scaffold(
      body: Container(
          child: SafeArea(
              child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                height: 210,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.blue.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Opacity(
                      opacity: 0.2,
                      child: Align(
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/imeges/hexagon_pattern.jpg',
                          // Add a geometric pattern image
                          width: 400,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Get the Best \nMedical Services',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'We  provide best quality medical\nservices without further cost.',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.blue[800],
                            ),
                          ),
                          SizedBox(height: 15),
                          ElevatedButton(
                            onPressed: () {
                              // Add your onPressed code here!
                            },
                            child: Text('Check Now'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue[900],
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                              textStyle: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Popular Doctors',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 19,
                      color: AppColors.secondaryColor2,
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.doctorsListScreen);
                    },
                    child: Text(
                      'See All',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 210.h,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 16, left: 16),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: userService.getAllDoctors(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text("No doctors found"));
                    } else {
                      final doctors = snapshot.data!;
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: doctors.length < 6 ? doctors.length : 6,
                        itemBuilder: (context, index) {
                          final doctor = doctors[index];
                          return DoctorCard(
                            doctor: doctor,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DoctorDetailsScreen(doctor: doctor),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Upcoming Appointments',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 19,
                          color: AppColors.secondaryColor2,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  AppointmentCard(
                    day: "Tue",
                    date: "12",
                    time: "09:30 AM",
                    doctorName: "Dr. Mim Ankht",
                    specialty: "Depression",
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  AppointmentCard(
                    day: "Tue",
                    date: "16",
                    time: "09:30 AM",
                    doctorName: "Dr. Mim Ankht",
                    specialty: "Depression",
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  AppointmentCard(
                    day: "Tue",
                    date: "12",
                    time: "09:30 AM",
                    doctorName: "Dr. Mim Ankht",
                    specialty: "Depression",
                  ),
                ],
              ),
            ),
          ],
        ),
      ))),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.chatScreen);
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.message_rounded),
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final String day;
  final String date;
  final String time;
  final String doctorName;
  final String specialty;

  const AppointmentCard({
    Key? key,
    required this.day,
    required this.date,
    required this.time,
    required this.doctorName,
    required this.specialty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  date,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  day,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  doctorName,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  specialty,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Icon(Icons.more_vert, color: Colors.white),
        ],
      ),
    );
  }
}
