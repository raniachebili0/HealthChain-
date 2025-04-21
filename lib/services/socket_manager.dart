import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import 'dart:convert';

enum ConnectionStatus {
  connected,
  disconnected,
  connecting,
  failed,
}

class SocketManager {
  // Singleton instance
  static final SocketManager _instance = SocketManager._internal();
  factory SocketManager() => _instance;
  SocketManager._internal();
  
  // Socket instance
  io.Socket? _socket;
  io.Socket? get socket => _socket;
  
  // Connection status
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  ConnectionStatus get connectionStatus => _connectionStatus;
  
  // Stream controller for connection status
  final _connectionStatusController = StreamController<ConnectionStatus>.broadcast();
  Stream<ConnectionStatus> get connectionStatusStream => _connectionStatusController.stream;
  
  // Connection parameters
  String? _baseUrl;
  String? _token;
  String? _userId;
  
  // Last error information
  String? _lastError;
  DateTime? _lastErrorTime;
  String? get lastError => _lastError;
  
  // Reconnection configuration
  final int _initialReconnectDelay = 1000; // 1 second
  final int _maxReconnectDelay = 30000; // 30 seconds
  int _currentReconnectDelay = 1000;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  
  // Heartbeat configuration
  Timer? _heartbeatTimer;
  final int _heartbeatInterval = 10000; // 10 seconds
  
  // Initialize socket with connection parameters
  Future<bool> initialize({String? token, String? userId, String? baseUrl}) async {
    debugPrint('[SOCKET] Initializing SocketManager');
    
    // Store connection parameters
    _baseUrl = baseUrl ?? ApiConfig.socketUrl;
    
    // Get token from storage if not provided
    if (token == null || token.isEmpty) {
      final storage = FlutterSecureStorage();
      _token = await storage.read(key: 'auth_token');
    } else {
      _token = token;
    }
    
    // Get user ID from storage if not provided
    if (userId == null || userId.isEmpty) {
      final storage = FlutterSecureStorage();
      _userId = await storage.read(key: 'user_id');
    } else {
      _userId = userId;
    }
    
    // Add detailed logging of parameters
    debugPrint('[SOCKET] Configuration: baseUrl: $_baseUrl, userId: $_userId, token: ${_token != null ? 'Present (${_token!.substring(0, 10)}...)' : 'Missing'}');
    
    // Don't proceed if we don't have a token
    if (_token == null || _token!.isEmpty) {
      _lastError = 'Authentication token missing';
      _lastErrorTime = DateTime.now();
      debugPrint('[SOCKET] No auth token available, cannot connect');
      _updateConnectionStatus(ConnectionStatus.failed);
      return false;
    }
    
    // Don't proceed if we don't have a baseUrl
    if (_baseUrl == null || _baseUrl!.isEmpty) {
      debugPrint('[SOCKET] No baseUrl provided, using default socket URL from ApiConfig');
      _baseUrl = ApiConfig.socketUrl;
    }
    
    if (_baseUrl == null || _baseUrl!.isEmpty) {
      _lastError = 'Socket URL not configured';
      _lastErrorTime = DateTime.now();
      debugPrint('[SOCKET] Socket URL is empty, cannot connect');
      _updateConnectionStatus(ConnectionStatus.failed);
      return false;
    }
    
    // Create and configure the socket
    return _createSocketConnection();
  }
  
  // Create the actual socket connection
  Future<bool> _createSocketConnection() async {
    try {
      _updateConnectionStatus(ConnectionStatus.connecting);
      
      // Disconnect existing socket if needed
      if (_socket != null) {
        _socket!.disconnect();
        _socket!.dispose();
        _socket = null;
      }
      
      // Clear any existing timers
      _reconnectTimer?.cancel();
      _heartbeatTimer?.cancel();
      
      // Create new socket with proper configuration
      debugPrint('[SOCKET] Creating new socket connection to: $_baseUrl');
      // Check if token is JWT and actually valid
      try {
        if (_token != null && _token!.split('.').length == 3) {
          final parts = _token!.split('.');
          if (parts.length >= 2) {
            // Fix base64 padding
            String payload = parts[1];
            payload = base64.normalize(payload);
            
            final payloadMap = json.decode(utf8.decode(base64.decode(payload)));
            final expiry = payloadMap['exp'];
            if (expiry != null) {
              final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiry * 1000);
              if (DateTime.now().isAfter(expiryDate)) {
                debugPrint('[SOCKET] Token has expired at $expiryDate, attempting to connect anyway');
              } else {
                debugPrint('[SOCKET] Token is valid until $expiryDate');
              }
            }
          }
        }
      } catch (e) {
        debugPrint('[SOCKET] Error checking token validity: $e');
      }
      
      final options = <String, dynamic>{
        'transports': ['websocket', 'polling'],
        'autoConnect': true,
        'reconnection': false, // We'll handle reconnection ourselves
        'extraHeaders': {
          'Authorization': 'Bearer $_token',
        },
        'forceNew': true,
        'timeout': 10000 // 10 second timeout for connection attempts
      };
      
      debugPrint('[SOCKET] Connection options: ${options.toString()}');
      _socket = io.io(_baseUrl!, options);
      
      // Register event handlers
      _registerEventHandlers();
      
      // Connect to the server
      if (!(_socket?.connected ?? false)) {
        _socket?.connect();
        debugPrint('[SOCKET] Connect method called on socket');
      }
      
      return true;
    } catch (e) {
      _lastError = 'Error creating connection: $e';
      _lastErrorTime = DateTime.now();
      debugPrint('[SOCKET] Error creating socket connection: $e');
      _updateConnectionStatus(ConnectionStatus.failed);
      _scheduleReconnect();
      return false;
    }
  }
  
  // Register socket event handlers
  void _registerEventHandlers() {
    if (_socket == null) return;
    
    // Connection established
    _socket!.onConnect((_) {
      debugPrint('[SOCKET] Connection established successfully');
      _updateConnectionStatus(ConnectionStatus.connected);
      
      // Reset reconnection parameters
      _currentReconnectDelay = _initialReconnectDelay;
      _reconnectAttempts = 0;
      _lastError = null;
      
      // Start heartbeat to keep connection alive
      _startHeartbeat();
      
      // Emit an initial identification event with the user ID
      if (_userId != null && _userId!.isNotEmpty) {
        _socket!.emit('identify', {'userId': _userId});
        debugPrint('[SOCKET] Sent identification with userId: $_userId');
      }
    });
    
    // Connection error
    _socket!.onConnectError((error) {
      _lastError = 'Connection error: $error';
      _lastErrorTime = DateTime.now();
      debugPrint('[SOCKET] Connection error: $error');
      _updateConnectionStatus(ConnectionStatus.failed);
      _scheduleReconnect();
    });
    
    // Disconnected
    _socket!.onDisconnect((reason) {
      _lastError = 'Disconnected: $reason';
      _lastErrorTime = DateTime.now();
      debugPrint('[SOCKET] Disconnected: $reason');
      _updateConnectionStatus(ConnectionStatus.disconnected);
      _scheduleReconnect();
    });
    
    // Error event
    _socket!.onError((error) {
      _lastError = 'Socket error: $error';
      _lastErrorTime = DateTime.now();
      debugPrint('[SOCKET] Socket error: $error');
      // Don't change status here, just log the error
    });
    
    // Reconnect attempt
    _socket!.onReconnect((attempt) {
      debugPrint('[SOCKET] Reconnecting (attempt $attempt)...');
      _updateConnectionStatus(ConnectionStatus.connecting);
    });
    
    // Reconnect failed
    _socket!.onReconnectFailed((_) {
      _lastError = 'Reconnection failed';
      _lastErrorTime = DateTime.now();
      debugPrint('[SOCKET] Reconnection failed');
      _updateConnectionStatus(ConnectionStatus.failed);
      _scheduleReconnect();
    });
    
    // Add a callback for socket.io library events as well
    _socket!.on('connect_timeout', (_) {
      _lastError = 'Connection timeout';
      _lastErrorTime = DateTime.now();
      debugPrint('[SOCKET] Connection timeout');
      _updateConnectionStatus(ConnectionStatus.failed);
    });
    
    _socket!.on('connect_error', (error) {
      _lastError = 'Connection error: $error';
      _lastErrorTime = DateTime.now();
      debugPrint('[SOCKET] Connection error from event: $error');
      _updateConnectionStatus(ConnectionStatus.failed);
    });
  }
  
  // Schedule a reconnection attempt
  void _scheduleReconnect() {
    // Cancel any existing reconnect timer
    _reconnectTimer?.cancel();
    
    // Increment reconnect attempts
    _reconnectAttempts++;
    
    // Calculate delay with exponential backoff
    _currentReconnectDelay = _currentReconnectDelay * 2;
    if (_currentReconnectDelay > _maxReconnectDelay) {
      _currentReconnectDelay = _maxReconnectDelay;
    }
    
    debugPrint('[SOCKET] Scheduling reconnect in ${_currentReconnectDelay}ms (attempt $_reconnectAttempts)');
    
    // Schedule reconnection
    _reconnectTimer = Timer(Duration(milliseconds: _currentReconnectDelay), () {
      debugPrint('[SOCKET] Attempting reconnection #$_reconnectAttempts...');
      _createSocketConnection();
    });
  }
  
  // Update connection status and notify listeners
  void _updateConnectionStatus(ConnectionStatus status) {
    if (_connectionStatus != status) {
      _connectionStatus = status;
      _connectionStatusController.add(status);
      debugPrint('[SOCKET] Connection status updated to: $status');
    }
  }
  
  // Start heartbeat to keep connection alive
  void _startHeartbeat() {
    // Cancel any existing heartbeat timer
    _heartbeatTimer?.cancel();
    
    // Create new heartbeat timer
    _heartbeatTimer = Timer.periodic(Duration(milliseconds: _heartbeatInterval), (_) {
      if (_socket?.connected ?? false) {
        debugPrint('[SOCKET] Sending heartbeat');
        _socket!.emit('heartbeat', {'userId': _userId});
      } else {
        debugPrint('[SOCKET] Heartbeat failed - socket not connected');
        _heartbeatTimer?.cancel();
        
        // Try to reconnect if not already connecting
        if (_connectionStatus != ConnectionStatus.connecting) {
          _scheduleReconnect();
        }
      }
    });
  }
  
  // Manually trigger a reconnection
  Future<bool> reconnect() async {
    debugPrint('[SOCKET] Manual reconnection requested');
    
    // Cancel any scheduled reconnection
    _reconnectTimer?.cancel();
    
    // Reset reconnection parameters
    _currentReconnectDelay = _initialReconnectDelay;
    _reconnectAttempts = 0;
    
    // Attempt to reconnect
    return _createSocketConnection();
  }
  
  // Emit an event with optional acknowledgment
  void emit(String event, dynamic data, {Function? ack}) {
    if (_socket == null || !(_socket?.connected ?? false)) {
      debugPrint('[SOCKET] Cannot emit event: socket not connected');
      
      // Trigger reconnection if not already in progress
      if (_connectionStatus != ConnectionStatus.connecting) {
        _scheduleReconnect();
      }
      
      return;
    }
    
    try {
      if (ack != null) {
        _socket!.emitWithAck(event, data, ack: ack);
      } else {
        _socket!.emit(event, data);
      }
    } catch (e) {
      debugPrint('[SOCKET] Error emitting event: $e');
    }
  }
  
  // Listen for a specific event
  void on(String event, Function(dynamic) handler) {
    if (_socket == null) {
      debugPrint('[SOCKET] Cannot register event listener: socket not initialized');
      return;
    }
    
    _socket!.on(event, handler);
  }
  
  // Remove listener for a specific event
  void off(String event) {
    if (_socket == null) {
      return;
    }
    
    _socket!.off(event);
  }
  
  // Clean up resources
  void dispose() {
    debugPrint('[SOCKET] Disposing SocketManager');
    
    // Cancel timers
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    
    // Disconnect socket
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
    
    // Close stream controller
    _connectionStatusController.close();
  }
  
  // Get diagnostic information
  Map<String, dynamic> getDiagnosticInfo() {
    return {
      'connectionStatus': _connectionStatus.toString(),
      'reconnectAttempts': _reconnectAttempts,
      'currentReconnectDelay': _currentReconnectDelay,
      'lastError': _lastError,
      'lastErrorTime': _lastErrorTime?.toIso8601String(),
      'socketConnected': _socket?.connected,
      'baseUrl': _baseUrl,
      'userIdAvailable': _userId != null && _userId!.isNotEmpty,
      'tokenAvailable': _token != null && _token!.isNotEmpty,
    };
  }
}