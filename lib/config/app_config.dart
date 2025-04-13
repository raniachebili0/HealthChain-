class AppConfig {
  // Base URL for all API requests
  // Using your local network IP to allow communication across devices
  static const String apiBaseUrl = "http://192.168.0.107:3001";
  
  // Auth endpoints
  static const String authBaseUrl = "$apiBaseUrl/auth";
  static const String loginUrl = "$authBaseUrl/login";
  static const String signupUrl = "$authBaseUrl/signup";
  static const String sendOtpUrl = "$authBaseUrl/sendOtp";
  static const String verifyOtpUrl = "$authBaseUrl/verify-otp";
  
  // User endpoints
  static const String usersBaseUrl = "$apiBaseUrl/users";
  static const String doctorsUrl = "$usersBaseUrl/doctors";
  static const String getUserByIdUrl = "$usersBaseUrl/getbyId";
  
  // File upload endpoint
  static const String uploadsUrl = "$apiBaseUrl/uploads";
} 