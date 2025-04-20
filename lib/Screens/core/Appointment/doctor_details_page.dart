import 'package:flutter/material.dart';
import 'package:health_chain/Screens/core/Appointment/AddApointment.dart';
import 'package:health_chain/widgets/heartbeat_fab.dart';

class DoctorDetailsPage extends StatelessWidget {
  final Map<String, dynamic> doctor;

  const DoctorDetailsPage({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    // Vérifications de sécurité
    final String name = doctor['name']?.toString() ?? 'Non précisé';
    final String email = doctor['email']?.toString() ?? 'Non précisé';
    final String telecom = doctor['telecom']?.toString() ?? 'Non précisé';
    
    // Gestion dynamique de la spécialité
    String specialty = 'Non précisée';
    if (doctor['specialization'] != null) {
      specialty = doctor['specialization'].toString();
    } else if (doctor['practitioner'] is Map && doctor['practitioner']['specialty'] != null) {
      specialty = doctor['practitioner']['specialty'].toString();
    }

    // Affichage
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (doctor['photo'] != null && doctor['photo'].toString().startsWith('http'))
              Image.network(
                doctor['photo'],
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              )
            else
              Container(
                height: 200,
                color: Colors.grey.shade200,
                child: const Icon(Icons.person, size: 80, color: Colors.grey),
              ),
            const SizedBox(height: 16),
            Text("Nom : $name", style: const TextStyle(fontSize: 18, color: Colors.black)),
            Text("Email : $email", style: const TextStyle(fontSize: 16,color: Colors.black87)),
            Text("Télécom : $telecom", style: const TextStyle(fontSize: 16,color: Colors.black87)),
            Text("Spécialité : $specialty", style: const TextStyle(fontSize: 16,color: Colors.black87)),
          ],
        ),
      ),
      floatingActionButton: HeartbeatFAB(
        onPressed: () {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return AddAppointmentForm(
              doctorId: doctor['_id'],
              scrollController: scrollController,
            );
          },
        );
      },
    );
  },),
 // Use the custom button here
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
