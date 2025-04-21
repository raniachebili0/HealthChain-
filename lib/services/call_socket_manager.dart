import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config/api_config.dart';

enum CallConnectionStatus { disconnected, connecting, connected, reconnecting, error }

class CallSocketManager {
  io.Socket? _socket;
  String? _userId;
  String? _token;
  CallConnectionStatus _connectionStatus = CallConnectionStatus.disconnected;
  
  // Getters
  io.Socket? get socket => _socket;
  CallConnectionStatus get connectionStatus => _connectionStatus;
  
  // Initialize the socket connection with proper error handling
  Future<bool> initialize({
    required String token,
    required String userId,
    String? baseUrl,
  }) async {
    try {
      _token = token;
      _userId = userId;
      final url = baseUrl ?? ApiConfig.baseUrl;
      
      print('[CALL SOCKET] Initializing with URL: $url, userId: $userId');
      
      // Create socket with options
      _socket = io.io(
        '$url/calls',
        io.OptionBuilder()
          .setTransports(['websocket'])
          .enableForceNewConnection()
          .setExtraHeaders({
            'Authorization': 'Bearer $token',
          })
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .build(),
      );
      
      // Set up basic socket event listeners
      _setupSocketListeners();
      
      // Connect to socket
      _socket!.connect();
      _connectionStatus = CallConnectionStatus.connecting;
      
      // Wait for connection or timeout
      Completer<bool> connectionCompleter = Completer<bool>();
      
      // Setup timeout
      Timer connectionTimer = Timer(Duration(seconds: 10), () {
        if (!connectionCompleter.isCompleted) {
          print('[CALL SOCKET] Connection timeout');
          _connectionStatus = CallConnectionStatus.error;
          connectionCompleter.complete(false);
        }
      });
      
      // Listen for connection
      _socket!.once('connect', (_) {
        if (!connectionCompleter.isCompleted) {
          print('[CALL SOCKET] Connected successfully');
          _connectionStatus = CallConnectionStatus.connected;
          connectionTimer.cancel();
          connectionCompleter.complete(true);
        }
      });
      
      // Listen for connection error
      _socket!.once('connect_error', (error) {
        if (!connectionCompleter.isCompleted) {
          print('[CALL SOCKET] Connection error: $error');
          _connectionStatus = CallConnectionStatus.error;
          connectionTimer.cancel();
          connectionCompleter.complete(false);
        }
      });
      
      return await connectionCompleter.future;
    } catch (e) {
      print('[CALL SOCKET] Initialization error: $e');
      _connectionStatus = CallConnectionStatus.error;
      return false;
    }
  }
  
  // Setup basic socket event listeners
  void _setupSocketListeners() {
    _socket?.on('connect', (_) {
      print('[CALL SOCKET] Connected');
      _connectionStatus = CallConnectionStatus.connected;
      
      // Join user's room for incoming calls
      if (_userId != null) {
        _socket?.emit('join_user_room', {'userId': _userId});
        print('[CALL SOCKET] Joined user room: $_userId');
      }
    });
    
    _socket?.on('disconnect', (_) {
      print('[CALL SOCKET] Disconnected');
      _connectionStatus = CallConnectionStatus.disconnected;
    });
    
    _socket?.on('reconnecting', (attempt) {
      print('[CALL SOCKET] Reconnecting: attempt $attempt');
      _connectionStatus = CallConnectionStatus.reconnecting;
    });
    
    _socket?.on('reconnect', (_) {
      print('[CALL SOCKET] Reconnected');
      _connectionStatus = CallConnectionStatus.connected;
      
      // Rejoin user's room after reconnect
      if (_userId != null) {
        _socket?.emit('join_user_room', {'userId': _userId});
        print('[CALL SOCKET] Rejoined user room after reconnect: $_userId');
      }
    });
    
    _socket?.on('error', (error) {
      print('[CALL SOCKET] Error: $error');
      _connectionStatus = CallConnectionStatus.error;
    });
  }
  
  // Method to join a call room
  void joinCallRoom(String callId) {
    if (_socket != null && _connectionStatus == CallConnectionStatus.connected) {
      _socket!.emit('join_call_room', {
        'callId': callId,
        'userId': _userId,
      });
      print('[CALL SOCKET] Joined call room: $callId');
    } else {
      print('[CALL SOCKET] Cannot join call room: socket not connected');
    }
  }
  
  // Method to emit a call event
  void emitCallEvent(String event, Map<String, dynamic> data) {
    if (_socket != null && _connectionStatus == CallConnectionStatus.connected) {
      _socket!.emit(event, data);
      print('[CALL SOCKET] Emitted event: $event with data: $data');
    } else {
      print('[CALL SOCKET] Cannot emit event: socket not connected');
    }
  }
  
  // Method to listen for a call event
  void onCallEvent(String event, Function(dynamic) callback) {
    if (_socket != null) {
      _socket!.on(event, callback);
      print('[CALL SOCKET] Listening for event: $event');
    } else {
      print('[CALL SOCKET] Cannot listen for event: socket not initialized');
    }
  }
  
  // Method to remove a call event listener
  void offCallEvent(String event, [Function(dynamic)? callback]) {
    if (_socket != null) {
      if (callback != null) {
        _socket!.off(event, callback);
      } else {
        _socket!.off(event);
      }
      print('[CALL SOCKET] Removed listener for event: $event');
    }
  }
  
  // Method to disconnect and clean up
  void dispose() {
    print('[CALL SOCKET] Disposing call socket manager');
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
    _connectionStatus = CallConnectionStatus.disconnected;
    _userId = null;
    _token = null;
  }
  
  // Method to check if socket is connected
  bool isConnected() {
    return _socket != null && _socket!.connected;
  }
  
  // Method to reconnect socket
  Future<bool> reconnect() async {
    if (_socket != null && _token != null && _userId != null) {
      print('[CALL SOCKET] Attempting to reconnect');
      _socket!.connect();
      
      Completer<bool> reconnectionCompleter = Completer<bool>();
      
      Timer reconnectionTimer = Timer(Duration(seconds: 5), () {
        if (!reconnectionCompleter.isCompleted) {
          print('[CALL SOCKET] Reconnection timeout');
          reconnectionCompleter.complete(false);
        }
      });
      
      _socket!.once('connect', (_) {
        if (!reconnectionCompleter.isCompleted) {
          print('[CALL SOCKET] Reconnected successfully');
          reconnectionTimer.cancel();
          _connectionStatus = CallConnectionStatus.connected;
          reconnectionCompleter.complete(true);
        }
      });
      
      return await reconnectionCompleter.future;
    }
    
    return false;
  }
} 