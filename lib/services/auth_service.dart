import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:health_chain/services/NotificationService.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "http://10.0.2.2:3000/auth";
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
        print("OTP Verified Successfully: $responseData");
      } else {
        print("OTP Verification Failed: $responseData");
      }

      return responseData; // Return the response body as a string
    } catch (e) {
      print("Error verifying OTP: $e");
      return "Error verifying OTP: $e";
    }
  }

  Future<String> signup(
      {required String email,
      required String name,
      required String password,
      String? birthDate,
      String? gender,
      required String tel,
      required String role,
      File? filePath,
      String? doctorId,
      String? doctorspecility}) async {
    try {
      // ✅ Construire l'objet JSON pour `signupData`
      final Map<String, dynamic> signupData = {
        "email": email,
        "gender": gender,
        "name": name,
        "password": password,
        "birthDate": birthDate,
        "telecom": tel,
        "role": role,
        "specialization": doctorspecility,
        "licenseNumber": doctorId
      };

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.2.2:3000/auth/signup'), // Adjust for emulator
      );

      // ✅ Ajouter les données JSON comme champ de formulaire
      request.fields['signupData'] = jsonEncode(signupData);

      // ✅ Ajouter le fichier s'il existe
      if (filePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            filePath.path,
            filename: "profile.jpg",
          ),
        );
      }

      // ✅ Envoyer la requête
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print("✅ Response: $responseBody");

      if (response.statusCode == 200 || response.statusCode == 201) {
        var decodedResponse = jsonDecode(responseBody);
        return decodedResponse["message"] ?? "Signup successful";
      } else {
        return "Signup failed: ${response.reasonPhrase}";
      }
    } catch (e) {
      print("❌ Error during signup: $e");
      return "Error during signup: $e";
    }
  }

  // Step 4: Login User
  Future<String> login(String email, String password) async {
    try {
      String? userFCMToken = await NotificationService.getFCMToken();
      print("tokeeennnnnnn $userFCMToken ");
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "userFCMToken": userFCMToken,
        }),
      );

      print("Response received with status code: ${response.statusCode}");

      // Log the full response body for debugging
      final responseData = jsonDecode(response.body);
      print("Response body: $responseData");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Successful login, handle the tokens and user data
        String accessToken = responseData["accessToken"];
        String refreshToken = responseData["refreshToken"];
        String userId = responseData["userId"];
        String role = responseData["role"];

        await storage.write(key: "auth_token", value: accessToken);
        await storage.write(key: "user_role", value: role);
        await storage.write(key: "user_id", value: userId);
        print("Login successful, access token: $accessToken");

        return "Login successful";
      } else {
        // Log the error message in case of failure
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
