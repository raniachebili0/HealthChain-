import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_chain/config/app_config.dart';

class AuthService {
  final storage = FlutterSecureStorage();

  // Step 1: Send OTP
  Future<Map<String, dynamic>> sendOtp(String email) async {
    try {
      print("sendOtp function called with email: $email");
      final sendOtpUrl = AppConfig.sendOtpUrl.replaceAll(":3000", ":3001");
      print("Using sendOtp URL: $sendOtpUrl");

      final response = await http.post(
        Uri.parse(sendOtpUrl),
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
      final verifyOtpUrl = AppConfig.verifyOtpUrl.replaceAll(":3000", ":3001");
      print("Using verifyOtp URL: $verifyOtpUrl");

      final response = await http.post(
        Uri.parse(verifyOtpUrl),
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
      final signupUrl = AppConfig.signupUrl.replaceAll(":3000", ":3001");
      print("Using signup URL: $signupUrl");
      
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
        Uri.parse(signupUrl),
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
      final loginUrl = AppConfig.loginUrl.replaceAll(":3000", ":3001");
      print("Sending login request for email: $email to $loginUrl");
      
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print("Login request timed out after 10 seconds");
          throw TimeoutException("Connection timed out. Please check your server.");
        },
      );

      print("Response received with status code: ${response.statusCode}");

      try {
        // Log the full response body for debugging
        final responseData = jsonDecode(response.body);
        print("Response body: $responseData");

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Successful login, handle the tokens and user data
          if (responseData.containsKey("accessToken") && 
              responseData.containsKey("userId")) {
            
            String accessToken = responseData["accessToken"];
            String refreshToken = responseData["refreshToken"];
            String userId = responseData["userId"];
            String role = responseData["role"];

            print("Login successful for user: $userId with role: $role");
            
            await storage.write(key: "auth_token", value: accessToken);
            await storage.write(key: "user_id", value: userId);
            await storage.write(key: "user_role", value: role);
            
            print("Tokens stored in secure storage");
            
            return "Login successful";
          } else {
            print("Missing required fields in response: $responseData");
            return "Error: Incomplete response from server";
          }
        } else {
          // Log the error message in case of failure
          print("Login failed: ${responseData['message'] ?? responseData}");
          return "Error: ${responseData['message'] ?? "Login failed"}";
        }
      } catch (e) {
        // Handle JSON parsing errors
        print("Error parsing response: $e");
        print("Raw response: ${response.body}");
        return "Error: Unable to process server response";
      }
    } on TimeoutException catch (e) {
      print("Timeout exception: $e");
      return "Error: Server connection timed out. Please try again later.";
    } catch (e) {
      print("Exception during login: $e");
      return "Error: Connection problem. Please check your internet connection";
    }
  }

  // Logout
  Future<void> logout() async {
    await storage.delete(key: "auth_token");
    await storage.delete(key: "user_id");
    await storage.delete(key: "user_role");
  }
}
