import 'dart:convert';

import 'package:http/http.dart' as http;

class DoctorService {
  final String baseUrl = "http://127.0.0.1:3000/practitioners";

  Future<List<Map<String, dynamic>>> getAllDoctors() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/fetch"));

      print("Response received with status code: ${response.statusCode}");

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print(" $responseData");
        // Assuming the "data" key holds a list of doctors:
        return List<Map<String, dynamic>>.from(responseData);
      } else {
        print("Failed  $responseData");
        return []; // Return an empty list if failed
      }
    } catch (e) {
      return [
        {"error": "Error: $e"}
      ];
    }
  }
}
