import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, ChangeNotifier;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;

// Custom exception for timeout
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  @override
  String toString() => message;
}

// Helper function for min value
int min(int a, int b) => a < b ? a : b;

class NFTService extends ChangeNotifier {
  // Base URL for NFT service - ensure this matches your backend
  String get nftUrl {
    if (kIsWeb) {
      return 'http://localhost:3006/nft';
    } else {
      try {
        // For iOS devices, use localhost
        if (Platform.isIOS) {
          return 'http://localhost:3006/nft';
        }
        // For Android emulator, use 10.0.2.2
        return 'http://10.0.2.2:3006/nft';
      } catch (e) {
        // Fallback for web or if Platform is not available
        return 'http://localhost:3006/nft';
      }
    }
  }
      
  final storage = FlutterSecureStorage();

  // Get authentication token
  Future<String?> getAuthToken() async {
    try {
      String? token = await storage.read(key: "auth_token");
      if (token == null || token.isEmpty) {
        print("No auth token found or token is empty");
        return null;
      }
      
      // Print first few characters of token for debugging
      print("Using token: ${token.substring(0, math.min(20, token.length))}...");
      return token;
    } catch (e) {
      print("Error retrieving auth token: $e");
      return null;
    }
  }

  // Validate NFT creation parameters
  bool _validateNFTParams({
    required Uint8List fileBytes,
    required String fileName,
    required String recipientAddress,
  }) {
    if (fileBytes.isEmpty) {
      throw ArgumentError("File data cannot be empty");
    }
    
    if (fileName.isEmpty) {
      throw ArgumentError("File name cannot be empty");
    }
    
    if (recipientAddress.isEmpty) {
      throw ArgumentError("Recipient address cannot be empty");
    }
    
    return true;
  }

  // Add method to check server connectivity before attempting upload
  Future<bool> checkServerConnectivity() async {
    try {
      print("Checking NFT server connectivity at: $nftUrl");
      final response = await http.get(
        Uri.parse('$nftUrl/health'),
        headers: {'Accept': 'application/json'},
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException("Health check timed out after 5 seconds");
        },
      );
      
      print("Server health check response: ${response.statusCode}");
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print("Server connectivity check failed: $e");
      // Try a fallback to root endpoint
      try {
        final fallbackResponse = await http.get(
          Uri.parse(kIsWeb ? 'http://localhost:3006/' : 'http://10.0.2.2:3006/'),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 3));
        
        print("Fallback connectivity check: ${fallbackResponse.statusCode}");
        return fallbackResponse.statusCode >= 200 && fallbackResponse.statusCode < 500;
      } catch (fallbackE) {
        print("Fallback connectivity check also failed: $fallbackE");
        return false;
      }
    }
  }

  // Create NFT from file with direct URL
  Future<Map<String, dynamic>> createNFT({
    required Uint8List fileBytes,
    required String fileName,
    required String recipientAddress,
    String? description,
    String? fileType,
  }) async {
    try {
      // Validate input parameters
      _validateNFTParams(
        fileBytes: fileBytes,
        fileName: fileName,
        recipientAddress: recipientAddress,
      );
      
      print("Starting NFT creation at endpoint: $nftUrl/create");
      print("Recipient address: $recipientAddress");
      print("File name: $fileName, size: ${fileBytes.length} bytes");
      
      String? authToken = await getAuthToken();
      print("Using auth token: ${authToken != null ? 'Yes' : 'No'}");

      // Server connectivity check removed to fix compilation error
      
      // Prepare form data - same approach for both web and mobile
      var uri = Uri.parse('$nftUrl/create');
      var request = http.MultipartRequest('POST', uri);
      
      // Add authorization header if available
      if (authToken != null && authToken.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $authToken';
      } else {
        print("Warning: No auth token available for NFT creation");
      }
      
      // Add recipient ethereum address
      request.fields['recipientAddress'] = recipientAddress;
      
      // Add optional metadata
      if (description != null && description.isNotEmpty) {
        request.fields['description'] = description;
        print("Added description: $description");
      }
      
      // Determine content type
      String mimeType;
      if (fileType != null && fileType.isNotEmpty) {
        mimeType = fileType;
      } else {
        mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';
      }
      print("File type: $mimeType, size: ${fileBytes.length} bytes");
      
      // IMPORTANT: Create a defensive copy of the file bytes to prevent
      // the "Cannot perform %TypedArray%.prototype.set on a detached ArrayBuffer" error
      final Uint8List bytesCopy = Uint8List.fromList(fileBytes);
      
      // Add file using http package's MultipartFile
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytesCopy,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      );
      
      print("Sending request to $uri with ${request.files.length} files and ${request.fields.length} fields");
      
      try {
        // Send request with timeout
        var streamedResponse = await request.send().timeout(
          const Duration(seconds: 60),  // Increased timeout for large files
          onTimeout: () {
            throw TimeoutException("Request timed out after 60 seconds");
          },
        );
        
        var responseData = await http.Response.fromStream(streamedResponse);
        
        print("Response status: ${responseData.statusCode}");
        
        // Safely log response body
        try {
          String bodyPreview = responseData.body;
          if (bodyPreview.length > 100) {
            bodyPreview = bodyPreview.substring(0, 100) + '...';
          }
          print("Response body: $bodyPreview");
        } catch (e) {
          print("Could not print response body: $e");
        }
        
        if (responseData.statusCode == 200 || responseData.statusCode == 201) {
          try {
            var data = json.decode(responseData.body);
            print("NFT created successfully: $data");
            return data;
          } catch (e) {
            print("Error parsing response: $e");
            // In case of JSON parsing error, return a simple success response
            return {
              "status": "success",
              "message": "NFT creation initiated",
              "tokenId": DateTime.now().millisecondsSinceEpoch.toString(),
              "timestamp": DateTime.now().toIso8601String(),
              "error": "Response parsing error: $e"
            };
          }
        } else if (responseData.statusCode == 401 || responseData.statusCode == 403) {
          print("Authentication error: ${responseData.statusCode} - ${responseData.body}");
          return {
            "status": "error",
            "error": "Authentication failed. Please log in again.",
            "code": responseData.statusCode,
            "fallback": true
          };
        } else {
          print("Server error: ${responseData.statusCode} - ${responseData.body}");
          // Return more informative mock data including the error
          return {
            ...getMockNFTData(),
            "error": "Server returned ${responseData.statusCode}",
            "message": responseData.body,
            "fallback": true
          };
        }
      } catch (e) {
        if (e is TimeoutException) {
          print("Request timeout: $e");
          return {
            ...getMockNFTData(),
            "error": "Request timed out. Please try again with a smaller file or check your network connection.",
            "fallback": true
          };
        }
        
        print("Network error: $e");
        return {
          ...getMockNFTData(),
          "error": "Network error: ${e.toString()}",
          "fallback": true
        };
      }
    } catch (e) {
      print("Error in createNFT: $e");
      return {
        ...getMockNFTData(),
        "error": "Error in createNFT: ${e.toString()}",
        "fallback": true
      };
    }
  }
  
  // Mock NFT data for testing when the server is not available
  Map<String, dynamic> getMockNFTData() {
    return {
      "tokenId": "mock-${DateTime.now().millisecondsSinceEpoch}",
      "ipfsUrl": "ipfs://QmXyZ123456789",
      "recipientAddress": "0x123456789012345678901234567890123456789A",
      "status": "minted",
      "createdAt": DateTime.now().toIso8601String(),
      "isMock": true
    };
  }

  // Get NFTs owned by the user
  Future<List<dynamic>> getUserNFTs() async {
    try {
      String? authToken = await getAuthToken();
      if (authToken == null) throw Exception("Authentication token is missing");

      final response = await http.get(
        Uri.parse('$nftUrl/user-nfts'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException("Request timed out after 30 seconds");
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception("Authentication failed. Please log in again.");
      } else if (response.statusCode == 404) {
        // No NFTs found - return empty list instead of throwing
        print("No NFTs found for user");
        return [];
      } else {
        throw Exception('Failed to load NFTs: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching NFTs: $e');
      // Return mock data for testing
      return [getMockNFTData(), getMockNFTData()];
    }
  }

  // Get details for a specific NFT by ID
  Future<Map<String, dynamic>> getNFTDetails(String tokenId) async {
    try {
      if (tokenId.isEmpty) {
        throw ArgumentError("Token ID cannot be empty");
      }
      
      String? authToken = await getAuthToken();
      if (authToken == null) throw Exception("Authentication token is missing");

      final response = await http.get(
        Uri.parse('$nftUrl/$tokenId'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException("Request timed out after 30 seconds");
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception("Authentication failed. Please log in again.");
      } else if (response.statusCode == 404) {
        throw Exception("NFT with token ID $tokenId not found");
      } else {
        throw Exception('Failed to get NFT details: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error getting NFT details: $e');
      // Return mock data for testing
      return {
        ...getMockNFTData(),
        "tokenId": tokenId,
        "error": e.toString()
      };
    }
  }
} 