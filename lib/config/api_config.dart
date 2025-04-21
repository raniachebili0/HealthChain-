class ApiConfig {
  // Base URL for API calls
  static const String baseUrl = 'http://192.168.100.167:3000'; // For Android emulator
  //static const String baseUrl = 'http://127.0.0.1:3000'; // For iOS simulator
  //static const String baseUrl = 'http://YOUR_SERVER_IP:3000'; // For real devices
  
  // WebSocket URL for real-time communication
  static const String socketUrl = 'http://192.168.100.167:3000/chat'; // For Android emulator
  //static const String socketUrl = 'http://127.0.0.1:3000/chat'; // For iOS simulator
  //static const String socketUrl = 'http://YOUR_SERVER_IP:3000/chat'; // For real devices
  
  // API endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String messages = '/messages';
  static const String conversations = '/conversations';
  static const String users = '/users';
  
  // Timeouts
  static const int connectionTimeout = 10000; // 10 seconds (reduced from 30)
  static const int receiveTimeout = 10000; // 10 seconds (reduced from 30)
  
  // Socket configuration
  static const int maxRetryAttempts = 5;
  static const int initialBackoffDelay = 1000; // 1 second
  static const int maxBackoffDelay = 10000; // 10 seconds
  static const bool debugSocket = true; // Enable socket debugging

  // Application-wide constants

  // API related constants
  static const int API_TIMEOUT_SECONDS = 30;
  static const int MAX_RETRY_ATTEMPTS = 3;

  // Socket related constants
  static const int SOCKET_RECONNECT_DELAY_MS = 5000;
  static const int SOCKET_MAX_RECONNECT_ATTEMPTS = 10;
  static const int SOCKET_HEARTBEAT_INTERVAL_MS = 30000;

  // Chat related constants
  static const int MESSAGE_REFRESH_INTERVAL_MS = 5000;
  static const int TYPE_INDICATOR_TIMEOUT_MS = 3000;
  static const int MAX_MESSAGE_LENGTH = 1000;

  // Call related constants
  static const int CALL_TIMEOUT_SECONDS = 30;
  static const int CALL_RING_DURATION_SECONDS = 60;

  // UI related constants
  static const double AVATAR_SIZE_SMALL = 40.0;
  static const double AVATAR_SIZE_MEDIUM = 60.0;
  static const double AVATAR_SIZE_LARGE = 80.0;

  // Features and flags
  static const bool ENABLE_CALL_FEATURES = true;
  static const bool ENABLE_MESSAGE_REACTIONS = true;
  static const bool ENABLE_READ_RECEIPTS = true; 
} 