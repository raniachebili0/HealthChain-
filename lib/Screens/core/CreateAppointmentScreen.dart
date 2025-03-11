import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:health_chain/services/user_service.dart';

class CreateAppointmentScreen extends StatefulWidget {
  final String doctorId;

  const CreateAppointmentScreen({super.key, required this.doctorId});

  @override
  State<CreateAppointmentScreen> createState() =>
      _CreateAppointmentScreenState();
}

class _CreateAppointmentScreenState extends State<CreateAppointmentScreen> {
  final UserService userService = UserService();
  final _formKey = GlobalKey<FormState>();
  final storage = FlutterSecureStorage();
  String? doctorId;
  String? date;
  String? time;

  void submitAppointment() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Map<String, dynamic> appointmentData = {
        "doctorId": doctorId,
        "date": date,
        "time": time,
      };

      try {
        var response = await userService.createAppointment(appointmentData);
        print("Appointment Created: $response");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Appointment created successfully!")),
        );
      } catch (e) {
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to create appointment.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Appointment")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration:
                    const InputDecoration(labelText: "Date (YYYY-MM-DD)"),
                onSaved: (value) => date = value,
                validator: (value) =>
                    value!.isEmpty ? "Date is required" : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Time (HH:MM)"),
                onSaved: (value) => time = value,
                validator: (value) =>
                    value!.isEmpty ? "Time is required" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitAppointment,
                child: const Text("Create Appointment"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
