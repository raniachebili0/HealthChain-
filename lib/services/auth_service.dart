import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "http://10.0.2.2:3000/auth";

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

  // Step 3: Signup User
  Future<String> signup(String email, String gender, String name,
      String password, String birthDate, String tel, String role) async {
    try {
      // Creating the request body
      final Map<String, String> requestBody = {
        "email": email,
        "gender": gender,
        "name": name,
        "password": password,
        "birthDate": birthDate,
        "telecom": tel,
        "role": role,
      };

      // Sending the POST request to the signup endpoint
      final response = await http.post(
        Uri.parse("$baseUrl/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      print("Response received with status code: ${response.statusCode}");

      // Handling the response
      if (response.statusCode == 200 || response.statusCode == 201) {
        final String responseData = response.body;

        // Parsing the response message
        final Map<String, dynamic> responseJson = jsonDecode(responseData);
        if (responseJson["message"] == "success") {
          print("Signup Successful: ${responseJson["message"]}");
          return responseJson["message"];
        } else {
          print("Signup Failed: ${responseJson["message"]}");
          return responseJson["message"];
        }
      } else {
        print("Error: Failed to sign up. Status code: ${response.statusCode}");
        return "Error: Failed to sign up";
      }
    } catch (e) {
      print("Error during signup: $e");
      return "Error during signup: $e";
    }
  }

  // Step 4: Login User
  Future<String> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
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

        // Save tokens, userId, and role in secure storage or app state for future use
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
  }
}
