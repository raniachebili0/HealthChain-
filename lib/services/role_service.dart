import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RoleService {
  final String baseUrl;
  final FlutterSecureStorage storage;

  RoleService({
    String? baseUrl,
    FlutterSecureStorage? storage,
  })  : baseUrl = baseUrl ?? "http://localhost:3000", // 10.0.2.2 pour Android, localhost pour iOS
        storage = storage ?? const FlutterSecureStorage();



  dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Authentication failed');
    } else if (response.statusCode == 404) {
      throw Exception('Resource not found');
    } else {
      throw Exception(
        'Request failed with status: ${response.statusCode}. ${response.body}',
      );
    }
  }

  // Récupérer un rôle par son ID
Future<Map<String, dynamic>> getRoleById(String roleId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/roles/$roleId'));
    
    print('Role API response: ${response.statusCode} ${response.body}');
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load role - Status: ${response.statusCode}');
    }
  } catch (e) {
    print('Error in getRoleById: $e');
    throw e;
  }
}

  // Récupérer un rôle par son nom
  Future<Map<String, dynamic>> getRoleByName(String name) async {
    try {
      
      final response = await http.get(
        Uri.parse('$baseUrl/roles?name=$name')
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to get role by name: $e');
    }
  }

  // Récupérer tous les rôles
  Future<List<dynamic>> getAllRoles() async {
    try {
      
      final response = await http.get(
        Uri.parse('$baseUrl/roles/all')
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to get all roles: $e');
    }
  }

  // Créer un nouveau rôle
  Future<Map<String, dynamic>> createRole(Map<String, dynamic> roleData) async {
    try {
      
      final response = await http.post(
        Uri.parse('$baseUrl/roles'),
        body: json.encode(roleData),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to create role: $e');
    }
  }
}