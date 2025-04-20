import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/services/user_service.dart';
import 'package:intl/intl.dart';
import 'package:health_chain/utils/colors.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RdvScreen extends StatefulWidget {
  const RdvScreen({super.key});

  @override
  State<RdvScreen> createState() => _RdvScreenState();
}

class _RdvScreenState extends State<RdvScreen> with SingleTickerProviderStateMixin {
  final UserService userService = UserService();
  final storage = FlutterSecureStorage();
  late Future<List<dynamic>> futureAppointments;
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      String? token = await storage.read(key: "auth_token");
      if (token != null) {
        setState(() {
          futureAppointments = userService.getAppointments(token);
        });
      } else {
        print("No auth token found");
        setState(() {
          futureAppointments = Future.error("Please login to view appointments");
        });
      }
    } catch (e) {
      print("Error loading appointments: $e");
      setState(() {
        futureAppointments = Future.error("Error loading appointments: $e");
      });
    }
  }

  Future<void> _refreshAppointments() async {
    await _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Schedule',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: _refreshAppointments,
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black54,
              indicator: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(25),
              ),
              tabs: [
                Tab(text: 'Upcoming'),
                Tab(text: 'Completed'),
                Tab(text: 'Canceled'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAppointmentsList('upcoming'),
                _buildAppointmentsList('completed'),
                _buildAppointmentsList('canceled'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(String status) {
    return FutureBuilder<List<dynamic>>(
      future: futureAppointments,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Error loading appointments",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8.h),
                ElevatedButton(
                  onPressed: _refreshAppointments,
                  child: Text("Try Again"),
                ),
              ],
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "No appointments found",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8.h),
                ElevatedButton(
                  onPressed: _refreshAppointments,
                  child: Text("Refresh"),
                ),
              ],
            ),
          );
        } else {
          // Filter appointments based on status
          final appointments = snapshot.data!.where((appointment) {
            String appointmentStatus = (appointment['status'] ?? '').toLowerCase();
            if (status == 'upcoming') {
              return appointmentStatus == 'pending' || appointmentStatus == 'confirmed';
            } else if (status == 'completed') {
              return appointmentStatus == 'completed';
            } else if (status == 'canceled') {
              return appointmentStatus == 'canceled';
            }
            return false;
          }).toList();

          if (appointments.isEmpty) {
            return Center(
              child: Text(
                "No ${status} appointments",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[700],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshAppointments,
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                return _buildAppointmentCard(appointment);
              },
            ),
          );
        }
      },
    );
  }

  Widget _buildAppointmentCard(dynamic appointment) {
    String formattedDate = "";
    String formattedTime = "";
    
    try {
      if (appointment['startDateTime'] != null) {
        DateTime startDateTime = DateTime.parse(appointment['startDateTime']);
        formattedDate = DateFormat('dd/MM/yyyy').format(startDateTime);
        formattedTime = DateFormat('h:mm a').format(startDateTime);
      } else if (appointment['date'] != null) {
        // Fallback for old format
        DateTime date = DateTime.parse(appointment['date']);
        formattedDate = DateFormat('dd/MM/yyyy').format(date);
        formattedTime = appointment['time'] ?? '';
      }
    } catch (e) {
      print("Error formatting date/time: $e");
    }

    // Get practitioner details
    final practitioner = appointment['practitioner'] ?? {};
    final doctorName = practitioner['name'] ?? 'Doctor Name';
    final specialization = practitioner['specialization'] ?? 'Specialty';
    final imageUrl = practitioner['image'];

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorName,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        specialization,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: imageUrl != null
                      ? NetworkImage(imageUrl)
                      : null,
                  child: imageUrl == null
                      ? Icon(Icons.person_outline, color: Colors.grey[500], size: 30.sp)
                      : null,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 16.sp, color: Colors.grey[600]),
                SizedBox(width: 8.w),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(width: 16.w),
                Icon(Icons.access_time, size: 16.sp, color: Colors.grey[600]),
                SizedBox(width: 8.w),
                Text(
                  formattedTime,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[800],
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: appointment['status'] == 'Confirmed' ? Colors.green[50] : Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: appointment['status'] == 'Confirmed' ? Colors.green : Colors.orange,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        appointment['status'] ?? 'Pending',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: appointment['status'] == 'Confirmed' ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Handle cancel
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.grey[50],
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle reschedule
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Reschedule',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
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
}
