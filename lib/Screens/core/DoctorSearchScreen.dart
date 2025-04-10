import 'package:flutter/material.dart';

class DoctorSearchScreen extends StatelessWidget {
  final Function(String, String) onDoctorSelected;

  const DoctorSearchScreen({super.key, required this.onDoctorSelected});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> doctors = [
      {
        'name': 'Dr. Marcus Horizon',
        'avatar': 'https://via.placeholder.com/150'
      },
      {'name': 'Dr. Alysa Hana', 'avatar': 'https://via.placeholder.com/150'},
      {'name': 'Dr. Maria Elena', 'avatar': 'https://via.placeholder.com/150'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Search Doctor")),
      body: ListView.builder(
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
                backgroundImage: NetworkImage(doctors[index]['avatar']!)),
            title: Text(doctors[index]['name']!),
            onTap: () {
              onDoctorSelected(
                  doctors[index]['name']!, doctors[index]['avatar']!);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
