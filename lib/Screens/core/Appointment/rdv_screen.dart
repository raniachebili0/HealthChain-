
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:health_chain/Screens/core/Appointment/medical_assistant_chat_screen.dart';
import 'package:health_chain/services/user_service.dart';
import 'package:health_chain/utils/colors.dart';

class RdvScreen extends StatefulWidget {
  const RdvScreen({super.key});

  @override
  State<RdvScreen> createState() => _RdvScreenState();
}

class _RdvScreenState extends State<RdvScreen> {
  final UserService userService = UserService();
  late Future<List<dynamic>> futureAppointments;

  String selectedStatus = 'all'; // <- initialisation filtre
  bool isChatOpened = false;
  
  @override
  void initState() {
    super.initState();
    String token = "your-auth-token"; // Replace with actual token
    futureAppointments = userService.getAppointments(token);
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(title: const Text("Mes Rendez-vous")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatusFilter(), // Menu de filtre
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: futureAppointments,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Aucun rendez-vous trouvé"));
                  } else {
                    final appointments = snapshot.data!;
                    // 💡 Filtrage ici
                    final filtered = selectedStatus == 'all'
                        ? appointments
                        : appointments
                            .where((a) => a['status'] == selectedStatus)
                            .toList();

                    if (filtered.isEmpty) {
                      return const Center(child: Text("Aucun résultat pour ce statut"));
                    }

                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final appointment = filtered[index];
                        return _buildAppointmentCard(appointment);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // When an appointment status is confirmed, navigate to the chat screen
          if (selectedStatus == 'confirmed' && !isChatOpened) {
             setState(() {
              isChatOpened = true;
            });

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MedicalAssistantChatScreen()),
            );
          }
        },
        child: const Icon(Icons.chat),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildStatusFilter() {
  const statuses = ['all', 'pending', 'confirmed', 'cancelled'];

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  return DropdownButton<String>(
    value: selectedStatus,
    items: statuses
        .map(
          (status) => DropdownMenuItem(
            value: status,
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: _getStatusColor(status),
              ),
            ),
          ),
        )
        .toList(),
    onChanged: (value) {
      if (value != null) {
        setState(() {
          selectedStatus = value;
        });
      }
    },
    icon: const Icon(Icons.arrow_drop_down),
    dropdownColor: Colors.white,
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
                  "Status: ${appointment['status']}",
                  style:  TextStyle(
                      fontSize: 14, 
                      fontWeight: FontWeight.w500, 
                       color: _getStatusColor(appointment['status']),
                      ),
                      
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
  Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return Colors.orange;
    case 'confirmed':
      return Colors.green;
    case 'cancelled':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

}



