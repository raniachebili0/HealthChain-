import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/message.dart';

class MessageService {
  // Singleton pattern
  static final MessageService _instance = MessageService._internal();
  factory MessageService() => _instance;
  MessageService._internal();

  final storage = FlutterSecureStorage();
  
  // Get all messages from the database
  Future<List<Message>> getAllMessages() async {
    try {
      final token = await storage.read(key: 'auth_token');
      
      if (token == null) {
        print('[MESSAGE SERVICE] No auth token found');
        return [];
      }
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/messages/all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('[MESSAGE SERVICE] Successfully fetched ${data.length} messages');
        
        return data.map((msg) => Message.fromJson(msg)).toList();
      } else {
        print('[MESSAGE SERVICE] Failed to load messages: ${response.statusCode}');
        print('[MESSAGE SERVICE] Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('[MESSAGE SERVICE] Error fetching all messages: $e');
      return [];
    }
  }
  
  // Get messages for a specific conversation
  Future<List<Message>> getMessagesByConversation(String conversationId) async {
    try {
      final token = await storage.read(key: 'auth_token');
      final userId = await storage.read(key: 'user_id');
      
      if (token == null) {
        print('[MESSAGE SERVICE] No auth token found');
        return [];
      }
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/messages/conversations/$conversationId/messages?userId=$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('[MESSAGE SERVICE] Successfully fetched ${data.length} messages for conversation: $conversationId');
        
        // Parse messages and sort by creation time
        final messages = data.map((msg) => Message.fromJson(msg)).toList();
        messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        
        return messages;
      } else {
        print('[MESSAGE SERVICE] Failed to load messages: ${response.statusCode}');
        print('[MESSAGE SERVICE] Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('[MESSAGE SERVICE] Error fetching messages for conversation: $e');
      return [];
    }
  }
  
  // Send a new message
  Future<Message?> sendMessage({
    required String content,
    required String conversationId,
    String? tempId,
  }) async {
    try {
      final token = await storage.read(key: 'auth_token');
      final userId = await storage.read(key: 'user_id');
      
      if (token == null || userId == null) {
        print('[MESSAGE SERVICE] No auth token or user ID found');
        return null;
      }
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/messages?userId=$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'content': content,
          'conversationId': conversationId,
          'tempId': tempId,
        }),
      );
      
      if (response.statusCode == 201) {
        print('[MESSAGE SERVICE] Message successfully sent');
        final messageData = json.decode(response.body);
        return Message.fromJson(messageData);
      } else {
        print('[MESSAGE SERVICE] Failed to send message: ${response.statusCode}');
        print('[MESSAGE SERVICE] Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('[MESSAGE SERVICE] Error sending message: $e');
      return null;
    }
  }
  
  // Mark messages as read
  Future<bool> markMessagesAsRead(String conversationId) async {
    try {
      final token = await storage.read(key: 'auth_token');
      final userId = await storage.read(key: 'user_id');
      
      if (token == null || userId == null) {
        print('[MESSAGE SERVICE] No auth token or user ID found');
        return false;
      }
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/messages/conversations/$conversationId/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'userId': userId,
        }),
      );
      
      if (response.statusCode == 200) {
        print('[MESSAGE SERVICE] Messages marked as read successfully');
        return true;
      } else {
        print('[MESSAGE SERVICE] Failed to mark messages as read: ${response.statusCode}');
        print('[MESSAGE SERVICE] Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('[MESSAGE SERVICE] Error marking messages as read: $e');
      return false;
    }
  }
} 