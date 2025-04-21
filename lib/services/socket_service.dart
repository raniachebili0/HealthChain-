import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import 'socket_manager.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  final storage = FlutterSecureStorage();
  io.Socket? socket;
  bool isInitialized = false;
  
  // Get socket manager instance
  final SocketManager _socketManager = SocketManager();
  
  // Connection status stream
  final _connectionStatusController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStatus => _connectionStatusController.stream;
  
  // Expose connection status
  ConnectionStatus get currentConnectionStatus => _socketManager.connectionStatus;
  bool get isConnected => _socketManager.connectionStatus == ConnectionStatus.connected;
  
  // Singleton pattern
  factory SocketService() {
    return _instance;
  }

  SocketService._internal();

  Future<void> initializeSocket() async {
    try {
      if (socket != null && socket!.connected) {
        print('[SOCKET] Socket already connected');
        return;
      }
      
      final token = await storage.read(key: 'auth_token');
      
      if (token == null) {
        print('[SOCKET] No auth token found');
        return;
      }
      
      print('[SOCKET] Initializing socket with URL: ${ApiConfig.socketUrl}');
      
      socket = io.io(
        ApiConfig.socketUrl,
        <String, dynamic>{
          'transports': ['websocket', 'polling'],
          'autoConnect': true,
          'extraHeaders': {'Authorization': 'Bearer $token'},
          'forceNew': true,
          'query': {'token': token}
        },
      );
      
      // Setup socket event handlers
      socket!.onConnect((_) {
        print('[SOCKET] Connected to server');
        _connectionStatusController.add(true);
      });
      
      socket!.onDisconnect((_) {
        print('[SOCKET] Disconnected from server');
        _connectionStatusController.add(false);
      });
      
      socket!.onError((error) {
        print('[SOCKET] Error: $error');
        _connectionStatusController.add(false);
      });
      
      socket!.onConnectError((error) {
        print('[SOCKET] Connection error: $error');
        _connectionStatusController.add(false);
      });
      
      // Add explicit debug logging for new_message event
      socket!.on('new_message', (data) {
        print('[SOCKET] Received new_message event: $data');
        // If data contains unreadCount, log it
        if (data != null && data is Map && data.containsKey('message')) {
          final message = data['message'];
          if (message is Map && message.containsKey('conversationId')) {
            print('[SOCKET] Message for conversation: ${message['conversationId']}');
          }
        }
      });
      
      print('[SOCKET] Socket initialized and connecting...');
      
    } catch (e) {
      print('[SOCKET] Error initializing socket: $e');
      _connectionStatusController.add(false);
    }
  }

  void disconnect() {
    // Use the socket manager's dispose method to clean up
    _socketManager.dispose();
    isInitialized = false;
  }

  Future<bool> reconnect() async {
    return await _socketManager.reconnect();
  }

  void emit(String event, dynamic data) {
    if (_socketManager.connectionStatus == ConnectionStatus.connected) {
      debugPrint("Emitting $event event: $data");
      _socketManager.emit(event, data);
    } else {
      debugPrint('Socket not connected, cannot emit $event. Attempting to reconnect...');
      _socketManager.reconnect();
      
      // Try again after a short delay if we're attempting to reconnect
      Future.delayed(Duration(milliseconds: 800), () {
        if (_socketManager.connectionStatus == ConnectionStatus.connected) {
          debugPrint("Emitting $event event after reconnection: $data");
          _socketManager.emit(event, data);
        } else {
          debugPrint("Still not connected after reconnection attempt. Event $event not sent.");
        }
      });
    }
  }
  
  // Method to listen for events with a proper cleanup function
  Function listenForEvent(String event, Function(dynamic) callback) {
    _socketManager.on(event, callback);
    
    // Return a function that can be called to remove this listener
    return () {
      _socketManager.off(event);
    };
  }
  
  // Get diagnostic information
  Map<String, dynamic> getDiagnosticInfo() {
    try {
      // Get diagnostic info from the socket manager
      final socketManagerDiagnostics = _socketManager.getDiagnosticInfo();
      
      // Add socket service specific information
      return {
        ...socketManagerDiagnostics,
        'serviceInitialized': isInitialized,
        'socketExists': socket != null,
      };
    } catch (e) {
      print('Error getting diagnostic info: $e');
      return {
        'error': 'Failed to get diagnostic info: $e',
        'connectionStatus': currentConnectionStatus.toString(),
        'serviceInitialized': isInitialized,
        'socketExists': socket != null,
      };
    }
  }
  
  // Reinitialize with fresh credentials
  Future<bool> reinitializeWithCredentials(String token, String userId) async {
    print('Reinitializing socket service with fresh credentials');
    
    // Disconnect and clean up existing socket
    disconnect();
    
    // Wait a moment before reconnecting
    await Future.delayed(Duration(milliseconds: 500));
    
    // Reinitialize with provided credentials
    final success = await _socketManager.initialize(
      token: token,
      userId: userId,
      baseUrl: ApiConfig.socketUrl
    );
    
    if (success) {
      // Get socket instance from the manager
      socket = _socketManager.socket;
      
      isInitialized = true;
      print('SocketService reinitialized successfully using fresh credentials');
      return true;
    } else {
      print('Failed to reinitialize SocketManager with fresh credentials');
      return false;
    }
  }
  
  // Clean up resources
  void dispose() {
    _socketManager.dispose();
    _connectionStatusController.close();
    isInitialized = false;
  }
} 