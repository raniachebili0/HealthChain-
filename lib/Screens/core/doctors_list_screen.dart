import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/Screens/core/docter_detailles_screnn.dart';
import 'package:health_chain/services/user_service.dart';
import 'package:health_chain/utils/colors.dart';
import 'package:health_chain/widgets/doctor_list_item.dart';

class Doctorslistscreen extends StatefulWidget {
  const Doctorslistscreen({super.key});

  @override
  State<Doctorslistscreen> createState() => _DoctorslistscreenState();
}

class _DoctorslistscreenState extends State<Doctorslistscreen> {
  final UserService userService = UserService();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allDoctors = [];
  List<Map<String, dynamic>> _filteredDoctors = [];

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
    _searchController.addListener(_filterDoctors);
  }

  Future<void> _fetchDoctors() async {
    try {
      final doctors = await userService.getAllDoctors();
      setState(() {
        _allDoctors = doctors;
        _filteredDoctors = doctors; // Initially, show all doctors
      });
    } catch (error) {
      print("Error fetching doctors: $error");
    }
  }

  void _filterDoctors() {
    String query = _searchController.text.toLowerCase();

    setState(() {
      _filteredDoctors = _allDoctors.where((doctor) {
        // Ensure values are strings and handle null safely
        String name = (doctor['name'] ?? '').toString().toLowerCase();
        String specialty = (doctor['specialty'] ?? '').toString().toLowerCase();

        return name.contains(query) || specialty.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              iconSize: 30,
              icon: Icon(Icons.notifications_rounded),
              color: Color(0xD25B5B5B),
              onPressed: () {},
            ),
          ),
        ],
        title: Text(
          'HealthChaine',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 30.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search doctors...',
                  hintStyle: TextStyle(color: Color(0xFF949393)),
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Color(0xFFCBE0F3),
                ),
              ),
            ),

            // Doctor List
            Expanded(
              child: _filteredDoctors.isEmpty
                  ? Center(child: Text("No doctors found"))
                  : ListView.builder(
                      itemCount: _filteredDoctors.length,
                      itemBuilder: (context, index) {
                        final doctor = _filteredDoctors[index];
                        return DoctorListCard(
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
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
