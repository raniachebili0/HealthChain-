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


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;
// import '../../models/rdvModel.dart';


// class RdvScreen extends StatefulWidget {
//   @override
//   _RdvScreenState createState() => _RdvScreenState();
// }

// class _RdvScreenState extends State<RdvScreen> {
//   // List to store fetched appointments
//   List<RdvModel> allAppointments = [];
//  final storage = FlutterSecureStorage();
//   @override
//   void initState() {
//     super.initState();
//     // Fetch appointments on screen load
//     _fetchAppointments();
//   }

//   // Fetch appointments from backend
//   Future<void> _fetchAppointments() async {
//     final url = 'http://127.0.0.1:3000/patient/appointments'; // Replace with your backend URL
   
//    String? token = await storage.read(key: "auth_token"); // Replace with the token obtained from login

//     try {
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $token', // Include the token for authentication
//         },
//       );

//       if (response.statusCode == 200) {
//         List<dynamic> data = json.decode(response.body);
//         setState(() {
//           allAppointments = data.map((appointment) => RdvModel.fromJson(appointment)).toList();
//         });
//       } else {
//         throw Exception('Failed to load appointments');
//       }
//     } catch (error) {
//       print('Error fetching appointments: $error');
//     }
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 3, // Number of tabs
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text("Appointments"),
//           bottom: TabBar(
//             tabs: const [
//               Tab(text: "Upcoming"),
//               Tab(text: "Completed"),
//               Tab(text: "Canceled"),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             _buildAppointmentList(_filterAppointments("Confirmed")), // Upcoming
//             _buildAppointmentList(_filterAppointments("Completed")), // Completed
//             _buildAppointmentList(_filterAppointments("Canceled")), // Canceled
//           ],
//         ),
//       ),
//     );
//   }

//   // Filter appointments by status
//  List<Map<String, String>> _filterAppointments(String status) {
// return allAppointments
//       .where((appointment) => appointment.data["status"] == status)
//       .map((appointment) => appointment.data)  // Récupérer directement la map des données
//       .toList();  }

  
//   // Build the appointment list
//   Widget _buildAppointmentList(List<Map<String, String>> appointments) {
//     if (appointments.isEmpty) {
//       return Center(child: Text("No appointments found"));
//     }
//     return ListView.builder(
//       padding: EdgeInsets.all(16.w),
//       itemCount: appointments.length,
//       itemBuilder: (context, index) {
//         var appointment = appointments[index];
//         return Card(
//           margin: EdgeInsets.only(bottom: 16.h),
//           elevation: 3,
//           child: Padding(
//             padding: EdgeInsets.all(16.w),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   appointment["doctorName"]!,
//                   style: TextStyle(
//                     fontSize: 18.sp,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 8.h),
//                 Text(
//                   appointment["specialty"]!,
//                   style: TextStyle(
//                     color: Colors.grey,
//                     fontSize: 14.sp,
//                   ),
//                 ),
//                 SizedBox(height: 8.h),
//                 Row(
//                   children: [
//                     Icon(Icons.calendar_today, size: 16.sp, color: Colors.grey),
//                     SizedBox(width: 5.w),
//                     Text(
//                       appointment["date"]!,
//                       style: TextStyle(fontSize: 14.sp),
//                     ),
//                     SizedBox(width: 15.w),
//                     Icon(Icons.access_time, size: 16.sp, color: Colors.grey),
//                     SizedBox(width: 5.w),
//                     Text(
//                       appointment["time"]!,
//                       style: TextStyle(fontSize: 14.sp),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 8.h),
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.circle,
//                       size: 12.sp,
//                       color: _getStatusColor(appointment["status"]!),
//                     ),
//                     SizedBox(width: 5.w),
//                     Text(
//                       appointment["status"]!,
//                       style: TextStyle(
//                         color: _getStatusColor(appointment["status"]!),
//                         fontSize: 14.sp,
//                       ),
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

//   // Get color based on status
//   Color _getStatusColor(String status) {
//     switch (status) {
//       case "Confirmed":
//         return Colors.green;
//       case "Completed":
//         return Colors.blue;
//       case "Canceled":
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }
// }
