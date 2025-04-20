import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/Screens/core/CreateAppointmentScreen.dart';
import 'package:health_chain/utils/colors.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DoctorDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> doctor;

  const DoctorDetailsScreen({Key? key, required this.doctor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Building DoctorDetailsScreen with data: $doctor");
    
    // Extract doctor information safely
    String doctorId = "";
    if (doctor.containsKey('_id') && doctor['_id'] != null) {
      doctorId = doctor['_id'];
    } else if (doctor.containsKey('id') && doctor['id'] != null) {
      doctorId = doctor['id'];
    } else {
      doctorId = "unknown";
    }
    
    // Get doctor name
    String doctorName = "";
    if (doctor.containsKey('name') && doctor['name'] != null) {
      doctorName = doctor['name'];
    } else if (doctor.containsKey('fullName') && doctor['fullName'] != null) {
      doctorName = doctor['fullName'];
    } else if (doctor.containsKey('firstName') && doctor['firstName'] != null) {
      String firstName = doctor['firstName'];
      String lastName = doctor.containsKey('lastName') && doctor['lastName'] != null 
          ? doctor['lastName'] 
          : "";
      doctorName = "$firstName $lastName".trim();
    } else {
      doctorName = "Unknown";
    }
    
    // Get specialization
    String specialization = "";
    if (doctor.containsKey('specialization') && doctor['specialization'] != null) {
      specialization = doctor['specialization'];
    } else if (doctor.containsKey('specialty') && doctor['specialty'] != null) {
      specialization = doctor['specialty'];
    } else if (doctor.containsKey('specialties') && doctor['specialties'] != null && doctor['specialties'] is List && doctor['specialties'].isNotEmpty) {
      specialization = doctor['specialties'][0];
    } else {
      specialization = "Specialist";
    }
    
    // Get photo URL
    String? photoUrl = null;
    if (doctor.containsKey('photo') && doctor['photo'] != null && doctor['photo'] != "null") {
      photoUrl = doctor['photo'];
    } else if (doctor.containsKey('profilePicture') && doctor['profilePicture'] != null && doctor['profilePicture'] != "null") {
      photoUrl = doctor['profilePicture'];
    } else if (doctor.containsKey('avatar') && doctor['avatar'] != null && doctor['avatar'] != "null") {
      photoUrl = doctor['avatar'];
    }
    
    if (photoUrl != null && !photoUrl.startsWith('http')) {
      // If the URL is relative, construct the full URL
      photoUrl = kIsWeb 
          ? "http://localhost:3006$photoUrl"  // Web browser
          : "http://10.0.2.2:3006$photoUrl";  // Android emulator
    }
    
    // Get rating
    double rating = 4.05; // Default value
    if (doctor.containsKey('rating') && doctor['rating'] != null) {
      if (doctor['rating'] is double) {
        rating = doctor['rating'];
      } else if (doctor['rating'] is int) {
        rating = doctor['rating'].toDouble();
      } else if (doctor['rating'] is String) {
        try {
          rating = double.parse(doctor['rating']);
        } catch (e) {
          // Keep default value if parsing fails
        }
      }
    }

    // Get experience
    String experience = "${(doctor['experience'] ?? 5)} years Experience";
    
    // Get bio/about
    String bio = doctor['bio'] ?? doctor['about'] ?? doctor['doctorBio'] ?? 
                "Experienced healthcare professional committed to providing excellent patient care.";
    
    // Get working hours
    String workingHours = doctor['workingHours'] ?? "Sat-Mon 10:30 AM-08:00PM";
    
    // Unique ID for the doctor
    String uniqueId = doctor['_id'] ?? doctor['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    
    return Scaffold(
      body: Stack(
        children: [
          // Content scrollable area
          CustomScrollView(
            slivers: [
              // App bar with doctor image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: Colors.white,
                leading: IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: photoUrl != null && photoUrl.startsWith('http')
                    ? Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print("Error loading image: $error");
                          return Image.asset(
                            'assets/imeges/defultDoctor.jpg',
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        'assets/imeges/defultDoctor.jpg',
                        fit: BoxFit.cover,
                      ),
                ),
                title: Text(
                  'Find Doctors',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              // Doctor info and details
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  transform: Matrix4.translationValues(0, -30, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Doctor name and specialty
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dr. $doctorName',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              specialization,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              experience,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Stats row (patients, rating)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                icon: Icons.people,
                                iconColor: Colors.blue,
                                label: "Patient",
                                value: "1000+",
                              ),
                            ),
                            Expanded(
                              child: _buildStatItem(
                                icon: Icons.star,
                                iconColor: Colors.amber,
                                label: "Rating",
                                value: rating.toStringAsFixed(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Specialties section
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 5, 20, 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Specialist',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildSpecialtyChip(specialization),
                                  _buildSpecialtyChip('Allergy'),
                                  _buildSpecialtyChip('STD'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Working time section
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Working time',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              workingHours,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // About section
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 80),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'About',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              bio,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Book Appointment button (fixed at bottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to appointment creation screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateAppointmentScreen(
                          doctorId: doctorId,
                          doctorData: doctor,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4DC0C9),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Book Appointment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem({
    required IconData icon, 
    required Color iconColor, 
    required String label, 
    required String value
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildSpecialtyChip(String name) {
    return Container(
      margin: EdgeInsets.only(right: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        name,
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
