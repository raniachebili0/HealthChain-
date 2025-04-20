import 'package:flutter/material.dart';
import 'package:health_chain/Screens/core/CreateAppointmentScreen.dart';

class DoctorDetailsViewModel extends ChangeNotifier {
  final Map<String, dynamic> doctor;

  DoctorDetailsViewModel({required this.doctor});

  void navigateToCreateAppointment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateAppointmentScreen(doctorId: doctor['_id']),
      ),
    );
  }

  String get doctorName => "Dr. ${doctor['name']}" ?? "User Name";
  String get doctorEmail => doctor['email'] ?? "User Email";
  String get doctorPhone => doctor['telecom'] ?? "User Tel";
  String get doctorPhoto => doctor['photo'];
  String get doctorBio => doctor['doctorbio'] ?? "No bio available";
  String get doctorAddress => doctor['address'] ?? "No address available";
  String get doctorSchedules => doctor['doctorhoraire'] ?? "No schedules available";
} 