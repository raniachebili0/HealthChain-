import 'dart:convert';

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
}
