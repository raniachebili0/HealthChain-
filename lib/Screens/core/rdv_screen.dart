// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:health_chain/models/rdvModel.dart';
// import 'package:health_chain/utils/colors.dart';
// import 'package:health_chain/widgets/button.dart';

// class RdvScreen extends StatelessWidget {
//   final List<RdvModel> appointments = [
//     RdvModel(
//       doctorName: "Dr. Marcus Horizon",
//       specialty: "Cardiologist",
//       date: "26/06/2022",
//       time: "10:30 AM",
//       status: "Confirmed",
//       image: "https://via.placeholder.com/50",
//     ),
//     RdvModel(
//       doctorName: "Dr. Alysa Hana",
//       specialty: "Psychiatrist",
//       date: "28/06/2022",
//       time: "2:00 PM",
//       status: "Completed",
//       image: "https://via.placeholder.com/50",
//     ),
//     RdvModel(
//       doctorName: "Dr. John Doe",
//       specialty: "Dermatologist",
//       date: "30/06/2022",
//       time: "4:00 PM",
//       status: "Canceled",
//       image: "https://via.placeholder.com/50",
//     ),
//   ];

//   RdvScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 3,
//       child: Scaffold(
//         body: Column(
//           children: [
//             Container(
//               margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
//               decoration: BoxDecoration(
//                 color: Colors.grey[200],
//                 borderRadius: BorderRadius.circular(20.r),
//               ),
//               child: TabBar(
//                 labelColor: Colors.black,
//                 unselectedLabelColor: Colors.black54,
//                 indicatorColor: AppColors.primaryColor,
//                 tabs: const [
//                   Tab(text: "Upcoming"),
//                   Tab(text: "Completed"),
//                   Tab(text: "Canceled"),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: TabBarView(
//                 children: [
//                   _buildAppointmentList(_filterAppointments("Confirmed")), // Upcoming
//                   _buildAppointmentList(_filterAppointments("Completed")), // Completed
//                   _buildAppointmentList(_filterAppointments("Canceled")), // Canceled
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   List<RdvModel> _filterAppointments(String status) {
//     return appointments.where((appointment) => appointment.status == status).toList();
//   }

//   Widget _buildAppointmentList(List<RdvModel> appointments) {
//     if (appointments.isEmpty) {
//       return Center(child: Text('No appointments found'));
//     }
//     return ListView.builder(
//       padding: EdgeInsets.all(16.w),
//       itemCount: appointments.length,
//       itemBuilder: (context, index) {
//         var appointment = appointments[index];
//         return Card(
//           shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12.r)),
//           margin: EdgeInsets.only(bottom: 16.h),
//           elevation: 3,
//           child: Padding(
//             padding: EdgeInsets.all(16.w),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     CircleAvatar(
//                       backgroundImage: NetworkImage(appointment.image),
//                       radius: 25.r,
//                     ),
//                     SizedBox(width: 12.w),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           appointment.doctorName,
//                           style: TextStyle(
//                               fontSize: 18.sp, fontWeight: FontWeight.bold),
//                         ),
//                         Text(
//                           appointment.specialty,
//                           style: TextStyle(color: Colors.grey, fontSize: 14.sp),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 12.h),
//                 Row(
//                   children: [
//                     Icon(Icons.calendar_today,
//                         size: 16.sp, color: Colors.grey),
//                     SizedBox(width: 5.w),
//                     Text(appointment.date, style: TextStyle(fontSize: 14.sp)),
//                     SizedBox(width: 15.w),
//                     Icon(Icons.access_time, size: 16.sp, color: Colors.grey),
//                     SizedBox(width: 5.w),
//                     Text(appointment.time, style: TextStyle(fontSize: 14.sp)),
//                     const Spacer(),
//                     Icon(Icons.circle, size: 12.sp, color: Colors.green),
//                     SizedBox(width: 5.w),
//                     Text(
//                       appointment.status,
//                       style: TextStyle(color: Colors.green, fontSize: 14.sp),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 12.h),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     MyButton(
//                       buttonText: "Cancel",
//                       buttonFunction: () {},
//                     ),
//                     MyButton(
//                       buttonText: "Reschedule",
//                       buttonFunction: () {},
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RdvScreen extends StatelessWidget {
  // Static list of appointments
  final List<Map<String, String>> allAppointments = [
    {
      "doctorName": "Dr. Marcus Horizon",
      "specialty": "Cardiologist",
      "date": "26/06/2022",
      "time": "10:30 AM",
      "status": "Confirmed",
    },
    {
      "doctorName": "Dr. Alysa Hana",
      "specialty": "Psychiatrist",
      "date": "28/06/2022",
      "time": "2:00 PM",
      "status": "Completed",
    },
    {
      "doctorName": "Dr. John Doe",
      "specialty": "Dermatologist",
      "date": "30/06/2022",
      "time": "4:00 PM",
      "status": "Canceled",
    },
  ];

  RdvScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text("Appointments"),
          bottom: TabBar(
            tabs: const [
              Tab(text: "Upcoming"),
              Tab(text: "Completed"),
              Tab(text: "Canceled"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAppointmentList(_filterAppointments("Confirmed")), // Upcoming
            _buildAppointmentList(_filterAppointments("Completed")), // Completed
            _buildAppointmentList(_filterAppointments("Canceled")), // Canceled
          ],
        ),
      ),
    );
  }

  // Filter appointments by status
  List<Map<String, String>> _filterAppointments(String status) {
    return allAppointments
        .where((appointment) => appointment["status"] == status)
        .toList();
  }

  // Build the appointment list
  Widget _buildAppointmentList(List<Map<String, String>> appointments) {
    if (appointments.isEmpty) {
      return Center(child: Text("No appointments found"));
    }
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        var appointment = appointments[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16.h),
          elevation: 3,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment["doctorName"]!,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  appointment["specialty"]!,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16.sp, color: Colors.grey),
                    SizedBox(width: 5.w),
                    Text(
                      appointment["date"]!,
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    SizedBox(width: 15.w),
                    Icon(Icons.access_time, size: 16.sp, color: Colors.grey),
                    SizedBox(width: 5.w),
                    Text(
                      appointment["time"]!,
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 12.sp,
                      color: _getStatusColor(appointment["status"]!),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      appointment["status"]!,
                      style: TextStyle(
                        color: _getStatusColor(appointment["status"]!),
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Get color based on status
  Color _getStatusColor(String status) {
    switch (status) {
      case "Confirmed":
        return Colors.green;
      case "Completed":
        return Colors.blue;
      case "Canceled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}