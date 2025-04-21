import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'audio_call_implementation.dart';
import '../../services/socket_manager.dart';
import 'package:health_chain/models/user.dart';
import '../../config/api_config.dart';

class CallHandlingService {
  // Singleton pattern
  static final CallHandlingService _instance = CallHandlingService._internal();
  factory CallHandlingService() => _instance;
  CallHandlingService._internal();

  // Services
  final SocketManager _socketManager = SocketManager();
  final storage = FlutterSecureStorage();
  
  // Stream controller for incoming calls
  final StreamController<User?> _incomingCallController = StreamController<User?>.broadcast();
  Stream<User?> get incomingCallStream => _incomingCallController.stream;
  
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Initialize socket connection
    await _initSocket();
    
    // Initialize connections
    _socketManager.connectionStatusStream.listen(_handleConnectionStatusChange);
    
    _isInitialized = true;
    debugPrint('[CALL_HANDLING] Service initialized');
  }
  
  Future<void> _initSocket() async {
    try {
      final token = await storage.read(key: 'auth_token');
      final userId = await storage.read(key: 'user_id');
      
      if (token == null || token.isEmpty) {
        debugPrint('[CALL_HANDLING] No auth token available, cannot initialize socket');
        return;
      }
      
      // Initialize the socket manager with the correct URL
      await _socketManager.initialize(
        token: token,
        userId: userId,
        baseUrl: ApiConfig.socketUrl
      );
    } catch (e) {
      debugPrint('[CALL_HANDLING] Error initializing socket: $e');
    }
  }
  
  void _handleConnectionStatusChange(ConnectionStatus status) {
    debugPrint('[CALL_HANDLING] Socket connection status changed: $status');
  }
  
  ConnectionStatus getConnectionStatus() {
    return _socketManager.connectionStatus;
  }
  
  Future<bool> reconnectSocket() async {
    return await _socketManager.reconnect();
  }
  
  void showIncomingCallUI(BuildContext context, User caller) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Incoming Call'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 30,
                child: Icon(Icons.person),
              ),
              SizedBox(height: 8),
              Text(
                caller.name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Decline'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AudioCallScreen(
                      remote: caller,
                      isIncoming: true,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('Accept'),
            ),
          ],
        );
      },
    );
  }
  
  Future<void> showOutgoingCallScreen(BuildContext context, User receiver) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AudioCallScreen(
          remote: receiver,
          isIncoming: false,
        ),
      ),
    );
  }
  
  void dispose() {
    if (!_incomingCallController.isClosed) {
      _incomingCallController.close();
    }
    _isInitialized = false;
  }
}