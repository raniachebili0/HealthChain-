import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/utils/colors.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/doctor_model.dart';

class DoctorCard extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final VoidCallback onTap;

  const DoctorCard({super.key, required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Log doctor data for debugging
    print("Building DoctorCard with data: $doctor");
  
    // Extract doctor name from various field possibilities
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
    
    // Extract specialization/specialty from various field possibilities
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
    
    // Extract photo URL from various field possibilities
    String? photoUrl = null;
    if (doctor.containsKey('photo') && doctor['photo'] != null && doctor['photo'] != "null") {
      photoUrl = doctor['photo'];
    } else if (doctor.containsKey('profilePicture') && doctor['profilePicture'] != null && doctor['profilePicture'] != "null") {
      photoUrl = doctor['profilePicture'];
    } else if (doctor.containsKey('avatar') && doctor['avatar'] != null && doctor['avatar'] != "null") {
      photoUrl = doctor['avatar'];
    }
    
    // If the URL is relative, construct the full URL
    if (photoUrl != null && !photoUrl.startsWith('http')) {
      photoUrl = kIsWeb 
          ? "http://localhost:3006$photoUrl"  // Web browser
          : "http://10.0.2.2:3006$photoUrl";  // Android emulator
    }
    
    print("Doctor name: $doctorName, specialization: $specialization, photo: $photoUrl");

    // Unique ID for the doctor
    String uniqueId = doctor['_id'] ?? doctor['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140.w,
        height: 170.h,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Doctor Image
            ClipRRect(
                borderRadius: const BorderRadius.all(
                  Radius.circular(30),
                ),
                child: Hero(
                  tag: "doctor_${uniqueId}",
                  child: photoUrl != null &&
                          photoUrl.toString().startsWith("http")
                      ? Image.network(
                          photoUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print("Error loading image: $error");
                            return Image.asset(
                              'assets/imeges/defultDoctor.jpg',
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/imeges/defultDoctor.jpg',
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                )),

            // Doctor Info
            Align(
              alignment: Alignment.bottomCenter,
              child: Opacity(
                opacity: 0.6,
                child: Container(
                  height: 55.h,
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor2,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, bottom: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 120.w,
                    child: Text(
                      "Dr. $doctorName",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    width: 120.w,
                    child: Text(
                      specialization,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
