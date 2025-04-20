import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  // Use localhost for web and 10.0.2.2 for Android emulators
  final String baseUrl = kIsWeb ? "http://localhost:3006/auth" : "http://10.0.2.2:3006/auth";
  final storage = FlutterSecureStorage();

  // Step 1: Send OTP
  Future<Map<String, dynamic>> sendOtp(String email) async {
    try {
      print("sendOtp function called with email: $email");

      final response = await http.post(
        Uri.parse("$baseUrl/sendOtp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      print("Response received with status code: ${response.statusCode}");

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("OTP Sent: ${responseData["otp"]}");
      } else {
        print("Failed to send OTP: ${responseData["message"]}");
      }

      return responseData; // Returns the full JSON response
    } catch (e) {
      print("Error sending OTP: $e");
      return {"error": "Error sending OTP: $e"};
    }
  }

  // Step 2: Verify OTP
  Future<String> verifyOtp(String email, String otp) async {
    try {
      print("verifyOtp function called with email: $email and otp: $otp");

      final response = await http.post(
        Uri.parse("$baseUrl/verify-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otp": otp}),
      );

      print("Response received with status code: ${response.statusCode}");

      // Directly use the response body since it's a plain string
      final String responseData = response.body;

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("OTP Verified Successfully: ${responseData}");
      } else {
        print("OTP Verification Failed: ${responseData}");
      }

      return responseData; // Return the response body as a string
    } catch (e) {
      print("Error verifying OTP: $e");
      return "Error verifying OTP: $e";
    }
  }

  Future<String> signup({
    required String email,
    required String name,
    required String password,
    String? birthDate,
    String? gender,
    required String tel,
    dynamic filePath,
  }) async {
    try {
      // Build the signup data object
      final Map<String, dynamic> signupData = {
        "email": email,
        "gender": gender,
        "name": name,
        "password": password,
        "birthDate": birthDate,
        "telecom": tel,
      };

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/signup'),
      );

      // Add JSON data as form field
      request.fields['signupData'] = jsonEncode(signupData);

      // Add file if it exists
      if (filePath != null) {
        if (kIsWeb && filePath is Uint8List) {
          // Web: Handle bytes directly
          request.files.add(
            http.MultipartFile.fromBytes(
              'file',
              filePath,
              filename: "profile.jpg",
            ),
          );
        } else if (filePath is String) {
          // Mobile: Handle string path
          request.files.add(
            await http.MultipartFile.fromPath(
              'file',
              filePath,
              filename: "profile.jpg",
            ),
          );
        } else if (!kIsWeb && filePath is File) {
          // For backward compatibility
          request.files.add(
            await http.MultipartFile.fromPath(
              'file',
              filePath.path,
              filename: "profile.jpg",
            ),
          );
        }
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print("Response: $responseBody");

      if (response.statusCode == 200 || response.statusCode == 201) {
        var decodedResponse = jsonDecode(responseBody);
        return decodedResponse["message"] ?? "Signup successful";
      } else {
        return "Signup failed: ${response.reasonPhrase}";
      }
    } catch (e) {
      print("Error during signup: $e");
      return "Error during signup: $e";
    }
  }

  Future<String> login(String email, String password) async {
    try {
      print("Attempting login with URL: $baseUrl/login");

      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      print("Response received with status code: ${response.statusCode}");

      final responseData = jsonDecode(response.body);
      print("Response body: $responseData");

      if (response.statusCode == 200 || response.statusCode == 201) {
        String accessToken = responseData["accessToken"];
        String userId = responseData["userId"];
        String role = responseData["role"] ?? "patient"; // Get role from response

        print("Token received: ${accessToken.substring(0, math.min(20, accessToken.length))}...");
        
        await storage.write(key: "auth_token", value: accessToken);
        await storage.write(key: "user_id", value: userId);
        await storage.write(key: "user_role", value: role); // Store the role

        print("Login successful, auth token stored");
        print("User role: $role");

        return "Login successful";
      } else {
        print("Login failed: ${responseData['message'] ?? responseData}");
        return "Error: ${responseData['message'] ?? responseData}";
      }
    } catch (e) {
      print("Error during login: $e");
      return "Error during login: $e";
    }
  }

  // Logout
  Future<void> logout() async {
    //String? token = await storage.read(key: "auth_token");
    await storage.delete(key: "auth_token");
  }
}
