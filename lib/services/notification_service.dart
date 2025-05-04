import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  final String baseUrl = "http://10.0.2.2:3000/notifications";
  final storage = FlutterSecureStorage();

  Future<List<dynamic>> getNotifications() async {
    try {
      String? authToken = await storage.read(key: "auth_token");
      if (authToken == null) throw Exception("Authentication token is missing");

      final response = await http.get(
        Uri.parse("$baseUrl/getnotifications"),
        headers: {
          "Authorization": "Bearer $authToken",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> notifications = json.decode(response.body);
        return notifications;
      } else {
        throw Exception(
            'Failed to fetch notifications: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching notifications: $e");
      throw Exception('Failed to fetch notifications: $e');
    }
  }
}
