import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:health_chain/services/UserRole.dart';
import 'package:http/http.dart' as http;

class UserService {
  // Base URL that works for both web and mobile
  final String baseUrl = kIsWeb 
      ? "http://localhost:3006/users"  // Web browser
      : "http://10.0.2.2:3006/users";  // Android emulator
  
  final String patientUrl = kIsWeb 
      ? "http://localhost:3006/patient"  // Web browser
      : "http://10.0.2.2:3006/patient";  // Android emulator
      
  final String filesUrl = kIsWeb 
      ? "http://localhost:3006/files"  // Web browser
      : "http://10.0.2.2:3006/files";  // Android emulator
      
  final storage = FlutterSecureStorage();

  Future<List<Map<String, dynamic>>> getAllDoctors() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/doctors"));

      print("Response received with status code: ${response.statusCode}");

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print(" ${responseData}");
        // Assuming the "data" key holds a list of doctors:
        return List<Map<String, dynamic>>.from(responseData);
      } else {
        print("Failed  ${responseData}");
        return []; // Return an empty list if failed
      }
    } catch (e) {
      print("Error getting doctors: $e");
      // Return mocked data for demonstration
      return getMockDoctors();
    }
  }

  // Mock data for doctors when the API fails
  List<Map<String, dynamic>> getMockDoctors() {
    return [
      {
        "_id": "mock1",
        "name": "Dr. Sarah Johnson",
        "specialization": "Cardiologist",
        "rating": 4.8,
        "photo": null
      },
      {
        "_id": "mock2",
        "name": "Dr. Michael Smith",
        "specialization": "Neurologist",
        "rating": 4.6,
        "photo": null
      },
      {
        "_id": "mock3",
        "name": "Dr. Emily Chen",
        "specialization": "Pediatrician",
        "rating": 4.9,
        "photo": null
      }
    ];
  }

  // Get user profile information including ethereum address
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      String? token = await storage.read(key: "auth_token");
      if (token == null) {
        print("No auth token found");
        return {"error": "No authentication token found"};
      }

      // Use direct URL for profile
      String url = "$baseUrl/profile";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return Map<String, dynamic>.from(responseData);
      } else {
        // Return mock data with ethereum address for testing
        return {
          "name": "Test User",
          "email": "test@example.com",
          "ethereumAddress": "0xf774b4c9cC47Bf77dFDb9013Cb4fB6a754c2F261",
        };
      }
    } catch (e) {
      print("Error getting user profile: $e");
      // Return mock data for testing
      return {
        "name": "Test User",
        "email": "test@example.com",
        "ethereumAddress": "0xf774b4c9cC47Bf77dFDb9013Cb4fB6a754c2F261",
      };
    }
  }

  Future<Map<String, dynamic>> getuserbyid() async {
    try {
      String? token = await storage.read(key: "auth_token");
      if (token == null) {
        print("No auth token found");
        return {"error": "No authentication token found"};
      }

      final response = await http.get(
        Uri.parse("$baseUrl/getbyId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json", // Ensure proper JSON handling
        },
      );

      print("Response received with status code: ${response.statusCode}");

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print(" ${responseData}");
        // Assuming the "data" key holds a list of doctors:
        return Map<String, dynamic>.from(responseData);
      } else {
        print("Failed  ${responseData}");
        return {}; // Return an empty list if failed
      }
    } catch (e) {
      return {"error": "Error: $e"};
    }
  }

  Future<Map<String, dynamic>> getuserbyidinfo(String userId) async {
    try {
      String? token = await storage.read(key: "auth_token");
      if (token == null) {
        print("No auth token found");
        return {"error": "No authentication token found"};
      }

      final response = await http.get(
        Uri.parse("$baseUrl/getuserinfo/$userId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json", // Ensure proper JSON handling
        },
      );

      print("Response received with status code: ${response.statusCode}");

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print(" ${responseData}");
        // Assuming the "data" key holds a list of doctors:
        return Map<String, dynamic>.from(responseData);
      } else {
        print("Failed  ${responseData}");
        return {}; // Return an empty list if failed
      }
    } catch (e) {
      return {"error": "Error: $e"};
    }
  }

  // Upload file method that handles both web and mobile
  Future<void> uploadFile(dynamic filePath) async {
    if (filePath == null) return;

    // Skip file operations when running on web
    if (kIsWeb) {
      print('File upload not implemented for web yet');
      return;
    }

    final uri = Uri.parse('$filesUrl/upload');
    var request = http.MultipartRequest('POST', uri);
    
    try {
      var pic = await http.MultipartFile.fromPath(
        'file',
        (filePath as File).path,
      );
      request.files.add(pic);

      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('File uploaded successfully');
      } else {
        print('Failed to upload file');
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  Future<bool> updateUserProfile(Map<String, String> updateData) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/update'),
        body: jsonEncode(updateData),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer <your-jwt-token>',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true; // Success
      } else {
        return false; // Failure
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<List<dynamic>> getAppointments(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$patientUrl/appointments'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load appointments');
      }
    } catch (e) {
      print('Error fetching appointments: $e');
      // Return mock data for demonstration
      return getMockAppointments();
    }
  }

  // Mock appointments data
  List<dynamic> getMockAppointments() {
    return [
      {
        "_id": "appt001",
        "practitioner": {
          "name": "Dr. John Smith",
          "email": "john.smith@example.com",
          "specialization": "Cardiologist"
        },
        "date": "2023-08-15",
        "time": "09:30 AM",
        "status": "Confirmed"
      },
      {
        "_id": "appt002",
        "practitioner": {
          "name": "Dr. Lisa Wong",
          "email": "lisa.wong@example.com",
          "specialization": "Dermatologist"
        },
        "date": "2023-08-22",
        "time": "02:00 PM",
        "status": "Pending"
      },
      {
        "_id": "appt003",
        "practitioner": {
          "name": "Dr. Robert Johnson",
          "email": "robert.johnson@example.com",
          "specialization": "Neurologist"
        },
        "date": "2023-08-30",
        "time": "11:15 AM",
        "status": "Confirmed"
      }
    ];
  }

  Future<Map<String, dynamic>> createAppointment(
      Map<String, dynamic> appointmentData) async {
    final url = Uri.parse("$patientUrl/appointment");
    String? token = await storage.read(key: "auth_token");
    try {
      print("Creating appointment with URL: $url");
      print("Appointment data: $appointmentData");
      
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(appointmentData),
      );

      print("Appointment response status: ${response.statusCode}");
      print("Appointment response body: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to create appointment: ${response.body}");
      }
    } catch (e) {
      print("Error creating appointment: $e");
      throw Exception("Error: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getDoctorsFromUsers() async {
    try {
      String? token = await storage.read(key: "auth_token");
      if (token == null) {
        print("No auth token found");
        return getMockDoctors(); // Return mock data if not authenticated
      }

      final response = await http.get(
        Uri.parse("$baseUrl/role/doctor"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("Response received for doctors with status code: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print("Doctors data: $responseData");
        return List<Map<String, dynamic>>.from(responseData);
      } else {
        print("Failed to get doctors: ${response.body}");
        return []; // Return an empty list if failed
      }
    } catch (e) {
      print("Error getting doctors: $e");
      // Return mocked data for demonstration
      return getMockDoctors();
    }
  }

  Future<List<Map<String, dynamic>>> fetchDoctorsFromEndpoint() async {
    try {
      final String url = kIsWeb 
          ? "http://localhost:3006/users/doctors"  // Web browser
          : "http://10.0.2.2:3006/users/doctors";  // Android emulator
      
      print("Fetching doctors from: $url");
      final response = await http.get(Uri.parse(url));
      
      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");
      
      if (response.statusCode == 200) {
        // Parse the response structure with doctors array inside an object
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        // Check if the response contains a 'doctors' field
        if (responseData.containsKey('doctors') && responseData['doctors'] is List) {
          print("Found doctors array with ${responseData['doctors'].length} doctors");
          final List<dynamic> doctorsData = responseData['doctors'];
          return doctorsData.map((doctor) => Map<String, dynamic>.from(doctor)).toList();
        } else {
          // If response is directly a list
          if (responseData is List) {
            print("Response is a direct list of doctors");
            return (responseData as List).map((doctor) => Map<String, dynamic>.from(doctor)).toList();
          }
          
          print("No doctors array found in the response");
          return getMockDoctors();
        }
      } else {
        print("Failed to fetch doctors, returning mock data");
        return getMockDoctors();
      }
    } catch (e) {
      print("Error fetching doctors: $e");
      return getMockDoctors();
    }
  }
}
