import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:health_chain/services/UserRole.dart';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl = "http://10.0.2.2:3000/users";
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
      return [
        {"error": "Error: $e"}
      ];
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

  Future<void> uploadFile(
    File? filePath,
  ) async {
    if (filePath == null) return;

    final uri = Uri.parse(
        'http://10.0.2.2:3000/files/upload'); // Change the URL to your actual server endpoint
    var request = http.MultipartRequest('POST', uri);
    var pic = await http.MultipartFile.fromPath(
      'file',
      filePath!.path,
    );
    request.files.add(pic);

    try {
      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('File uploaded successfully');
        // Handle successful response here
      } else {
        print('Failed to upload file');
        // Handle failure here
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  Future<bool> updateUserProfile(Map<String, String> updateData) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/update'), // Replace with your API endpoint
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
        Uri.parse('http://10.0.2.2:3000/patient/appointments'),
        headers: {
          'Authorization': 'Bearer $token', // Include authentication token
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load appointments');
      }
    } catch (e) {
      throw Exception('Error fetching appointments: $e');
    }
  }

  Future<Map<String, dynamic>> createAppointment(
      Map<String, dynamic> appointmentData) async {
    final url = Uri.parse("http://10.0.2.2:3000/patient/appointment");
    String? token = await storage.read(key: "auth_token");
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(appointmentData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to create appointment: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}
