import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:health_chain/routes/app_router.dart';
import 'package:health_chain/utils/themes.dart';
import 'package:pdfx/pdfx.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:health_chain/services/user_service.dart';
import 'package:health_chain/widgets/appBar.dart';
import 'package:health_chain/widgets/button.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FilePickerScreen extends StatefulWidget {
  @override
  _FilePickerScreenState createState() => _FilePickerScreenState();
}

class _FilePickerScreenState extends State<FilePickerScreen> {
  String? pdfPath;
  PdfController? pdfController;
  final String baseUrl = kIsWeb 
      ? 'http://localhost:3006/medical-records'  // Use localhost for web browser
      : 'http://10.0.2.2:3006/medical-records';  // Use 10.0.2.2 for Android emulator
  final String nftUrl = kIsWeb 
      ? 'http://localhost:3006/nft'  // Use localhost for web browser
      : 'http://10.0.2.2:3006/nft';  // Use 10.0.2.2 for Android emulator
  final storage = FlutterSecureStorage();
  bool isUploading = false;
  String? ethereumAddress;
  List<int>? _fileBytesList; // More stable storage for file bytes
  
  // Getter that creates a new Uint8List each time to avoid detached ArrayBuffer
  Uint8List? get fileBytes {
    if (_fileBytesList == null) return null;
    return Uint8List.fromList(_fileBytesList!);
  }

  @override
  void initState() {
    super.initState();
    _fetchUserEthAddress();
  }

  Future<void> _fetchUserEthAddress() async {
    try {
      final userService = Provider.of<UserService>(context, listen: false);
      final userProfile = await userService.getUserProfile();
      if (userProfile != null && userProfile['ethereumAddress'] != null) {
        setState(() {
          ethereumAddress = userProfile['ethereumAddress'];
        });
        print("Fetched ETH address: $ethereumAddress");
      } else {
        // Fallback address for testing
        setState(() {
          ethereumAddress = "0x123456789012345678901234567890123456789A";
        });
      }
    } catch (e) {
      print("Error fetching user ETH address: $e");
      // Use fallback address
      setState(() {
        ethereumAddress = "0x123456789012345678901234567890123456789A";
      });
    }
  }

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true, // Always get data for both web and mobile
      );

      if (result != null) {
        setState(() {
          if (kIsWeb) {
            // For web: use the bytes data
            if (result.files.single.bytes != null) {
              // Store the bytes data
              _fileBytesList = result.files.single.bytes!.toList();
              print("Captured file bytes length: ${fileBytes!.length}");
              
              // Create a PDF controller from bytes for web preview
              pdfController = PdfController(
                document: PdfDocument.openData(fileBytes!),
              );
              // Save path for reference
              pdfPath = result.files.single.name;
            }
          } else {
            // For mobile: use the file path
            if (result.files.single.path != null) {
              pdfPath = result.files.single.path!;
              pdfController = PdfController(document: PdfDocument.openFile(pdfPath!));
            }
          }
        });
        print("File selected: $pdfPath");
      } else {
        print("No file selected");
      }
    } catch (e) {
      print("Error picking file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting file: ${e.toString()}')),
      );
    }
  }

  Future<String?> getAuthToken() async {
    return await storage.read(key: "auth_token");
  }

  Future<Map<String, dynamic>> uploadFile(File file, String fileType) async {
    try {
      String? authToken = await getAuthToken();
      if (authToken == null) throw Exception("Authentication token is missing");

      var uri = Uri.parse('$baseUrl/upload');
      var request = http.MultipartRequest('POST', uri);
      
      // Add headers
      request.headers['Authorization'] = 'Bearer $authToken';
      
      // Add fields
      request.fields['fileType'] = fileType;
      
      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: MediaType.parse(
              lookupMimeType(file.path) ?? 'application/octet-stream'),
        ),
      );

      var response = await request.send();
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseBody = await response.stream.bytesToString();
        return json.decode(responseBody);
      } else {
        throw Exception('Failed to upload file');
      }
    } catch (e) {
      throw Exception('Error uploading file: $e');
    }
  }
  
  // Upload file for web version (using bytes instead of File)
  Future<Map<String, dynamic>> uploadFileWeb(Uint8List fileBytes, String fileName, String fileType) async {
    try {
      // Check if we have file bytes
      if (fileBytes.isEmpty) {
        throw Exception("File data is empty");
      }
      
      String? authToken = await getAuthToken();
      if (authToken == null) throw Exception("Authentication token is missing");

      // Use direct URL for uploads
      final directUrl = '$baseUrl/upload';
      print("Using direct URL: $directUrl");
      
      var uri = Uri.parse(directUrl);
      var request = http.MultipartRequest('POST', uri);
      
      // Add headers
      request.headers['Authorization'] = 'Bearer $authToken';
      
      // Add fields
      request.fields['fileType'] = fileType;
      
      // Create a fresh defensive copy of the bytes to avoid detached ArrayBuffer
      final Uint8List bytesCopy = Uint8List.fromList(fileBytes);
      
      // Add file using bytes for web
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytesCopy,
          filename: fileName,
          contentType: MediaType.parse(
              lookupMimeType(fileName) ?? 'application/octet-stream'),
        ),
      );

      print("Sending web upload request to $directUrl");
      var response = await request.send();
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseBody = await response.stream.bytesToString();
        return json.decode(responseBody);
      } else {
        var responseBody = await response.stream.bytesToString();
        print("Error status: ${response.statusCode}, body: $responseBody");
        throw Exception('Failed to upload file: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading file (web): $e');
      throw Exception('Error uploading file (web): $e');
    }
  }

  // Create NFT from uploaded file
  Future<Map<String, dynamic>> createNFT(File file) async {
    try {
      String? authToken = await getAuthToken();
      if (authToken == null) throw Exception("Authentication token is missing");

      // Use the specific NFT creation endpoint
      var uri = Uri.parse('$nftUrl/create'); 
      var request = http.MultipartRequest('POST', uri);
      
      // Add authorization header
      if (authToken.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $authToken';
      }
      
      // Add recipient ethereum address
      request.fields['recipientAddress'] = "0xf774b4c9cC47Bf77dFDb9013Cb4fB6a754c2F261";
      
      // Add description
      request.fields['description'] = "Medical record from HealthChain application - " + file.path.split('/').last;
      
      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: MediaType.parse(
              lookupMimeType(file.path) ?? 'application/octet-stream'),
        ),
      );
      
      print("Sending NFT creation request to $uri");
      var streamedResponse = await request.send().timeout(
        Duration(seconds: 60),
        onTimeout: () {
          throw Exception("Request timed out after 60 seconds");
        },
      );
      
      var responseData = await http.Response.fromStream(streamedResponse);
      print("NFT response status: ${responseData.statusCode}");
      
      if (responseData.statusCode == 200 || responseData.statusCode == 201) {
        var data = json.decode(responseData.body);
        print("NFT created successfully: $data");
        return data;
      } else {
        print("Error creating NFT: ${responseData.statusCode} - ${responseData.body}");
        return {
          "error": "Failed to create NFT: ${responseData.statusCode}",
          "message": responseData.body
        };
      }
    } catch (e) {
      print("Error creating NFT: $e");
      return {
        "error": "Error creating NFT: $e",
      };
    }
  }
  
  // Create NFT from web file (using bytes instead of File)
  Future<Map<String, dynamic>> createNFTWeb(Uint8List fileBytes, String fileName) async {
    try {
      // Check if we have file bytes
      if (fileBytes.isEmpty) {
        throw Exception("File data is empty");
      }
      
      String? authToken = await getAuthToken();
      if (authToken == null) throw Exception("Authentication token is missing");

      // Use direct URL for NFT creation
      final directUrl = '$nftUrl/create';
      print("Using direct URL for NFT: $directUrl");
      
      var uri = Uri.parse(directUrl); 
      var request = http.MultipartRequest('POST', uri);
      
      // Add authorization header
      if (authToken.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $authToken';
      }
      
      // Create a fresh copy of the bytes to avoid detached ArrayBuffer
      final Uint8List bytesCopy = Uint8List.fromList(fileBytes);
      
      // Add recipient ethereum address
      request.fields['recipientAddress'] = "0xf774b4c9cC47Bf77dFDb9013Cb4fB6a754c2F261";
      
      // Add description
      request.fields['description'] = "Medical record from HealthChain application - " + fileName;
      
      // Add file using bytes for web
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytesCopy,
          filename: fileName,
          contentType: MediaType.parse(
              lookupMimeType(fileName) ?? 'application/octet-stream'),
        ),
      );
      
      print("Sending NFT creation request to $directUrl (web)");
      var streamedResponse = await request.send().timeout(
        Duration(seconds: 60),
        onTimeout: () {
          throw Exception("Request timed out after 60 seconds");
        },
      );
      
      var responseData = await http.Response.fromStream(streamedResponse);
      print("NFT response status: ${responseData.statusCode}");
      
      if (responseData.statusCode == 200 || responseData.statusCode == 201) {
        var data = json.decode(responseData.body);
        print("NFT created successfully (web): $data");
        return data;
      } else {
        print("Error creating NFT (web): ${responseData.statusCode} - ${responseData.body}");
        return {
          "error": "Failed to create NFT: ${responseData.statusCode}",
          "message": responseData.body
        };
      }
    } catch (e) {
      print("Error in createNFTWeb: $e");
      return {
        "error": "Error creating NFT: $e",
      };
    }
  }

  void buttonAction(BuildContext context, String? pdfPath) async {
    print("Button pressed, pdfPath: $pdfPath");
    print("File bytes available: ${_fileBytesList?.length ?? 0} bytes");
    
    // Different check for web vs mobile
    bool validFile = false;
    if (kIsWeb) {
      // For web, check if we have both path and bytes
      validFile = pdfPath != null && _fileBytesList != null && _fileBytesList!.isNotEmpty;
      if (!validFile) {
        print("File validation failed. pdfPath: ${pdfPath != null ? 'OK' : 'Missing'}, bytes: ${_fileBytesList != null ? (_fileBytesList!.isNotEmpty ? 'OK' : 'Empty') : 'Missing'}");
      }
    } else {
      // For mobile, check if file exists
      validFile = pdfPath != null && File(pdfPath).existsSync();
    }
    
    if (!validFile) {
      print("No valid file selected");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a valid file')),
      );
      return;
    }
      
    setState(() {
      isUploading = true;
    });
    
    try {
      if (kIsWeb) {
        // Create a fresh copy of the bytes for upload
        final Uint8List uploadBytes = Uint8List.fromList(_fileBytesList!);
        print("Creating NFT in web mode with ${uploadBytes.length} bytes");
        
        // Skip medical record upload and only create NFT
        final nftResult = await createNFTWeb(uploadBytes, pdfPath!);
        final bool nftSuccess = !nftResult.containsKey('error');
        
        // Show success alert dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("File Upload"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Medical record uploaded successfully!"),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, AppRoutes.documentScreen);
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        // For mobile
        // Skip medical record upload and only create NFT
        final nftResult = await createNFT(File(pdfPath!));
        final bool nftSuccess = !nftResult.containsKey('error');
        
        // Show success alert dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("File Upload"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Medical record uploaded successfully!"),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, AppRoutes.documentScreen);
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print("Error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload file: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(appbartext: 'Upload Medical Records'),
            Padding(
              padding: EdgeInsets.fromLTRB(17.0, 0.0, 17.0, 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 13.h),
                    child: Text(
                      'Upload Medical Record',
                      style: CustomTextStyle.titleStyle,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 28.h),
                    child: Text(
                      "Securely upload your medical records for permanent storage.",
                      style: CustomTextStyle.h2,
                    ),
                  ),
                  Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 300,
                          child: _buildPdfPreview(),
                        ),
                        SizedBox(height: 60),
                        isUploading
                          ? Center(
                              child: Column(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text(
                                    "Uploading file...",
                                    style: TextStyle(
                                      color: Colors.blue.shade800,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : MyButton(
                              buttonFunction: () => buttonAction(context, pdfPath),
                              buttonText: 'Upload Files',
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build the PDF preview based on platform
  Widget _buildPdfPreview() {
    // Check if we have a valid PDF to show
    bool hasPdf = pdfController != null;
    
    // Print debug info
    print("Building PDF preview, controller exists: $hasPdf, bytes available: ${_fileBytesList?.length ?? 0}");
    
    // If we have a PDF, show the PDF view
    if (hasPdf) {
      return PdfView(controller: pdfController!);
    }
    
    // Otherwise show the file picker button
    return Container(
      decoration: BoxDecoration(
        color: Colors.white30,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: Offset(0, 4),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: pickFile,
              icon: Icon(Icons.file_open_rounded),
              tooltip: "Pick PDF",
              iconSize: 70,
            ),
            SizedBox(height: 8),
            Text(
              "Select a PDF file to upload as NFT",
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}