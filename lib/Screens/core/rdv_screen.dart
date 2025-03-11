import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:health_chain/services/user_service.dart';

class RdvScreen extends StatefulWidget {
  const RdvScreen({super.key});

  @override
  State<RdvScreen> createState() => _RdvScreenState();
}

class _RdvScreenState extends State<RdvScreen> {
  final UserService userService = UserService();
  late Future<List<dynamic>> futureAppointments;

  @override
  void initState() {
    super.initState();
    String token = "your-auth-token"; // Replace with actual token
    futureAppointments = userService.getAppointments(token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<dynamic>>(
          future: futureAppointments,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No Appointments Found"));
            } else {
              final appointments = snapshot.data!;
              return ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  return _buildAppointmentCard(appointment);
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(dynamic appointment) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appointment['practitioner']['name'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              appointment['practitioner']['email'],
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Appointment ID: ${appointment['_id']}",
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                Icon(Icons.calendar_today,
                    color: Colors.teal.shade400, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
