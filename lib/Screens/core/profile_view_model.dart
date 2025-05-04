import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:health_chain/routes/app_router.dart';
import 'package:health_chain/services/user_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserService _userService;
  final _storage = FlutterSecureStorage();
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _error;

  ProfileViewModel(this._userService);

  Map<String, dynamic>? get userData => _userData;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> loadUserData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userData = await _userService.getuserbyid();
      print("userrrrrrrr ${_userData}");
    } catch (e) {
      _error = e.toString();
      print("Error loading user data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await FirebaseMessaging.instance.deleteToken();
      await _storage.delete(key: "auth_token");
      await _storage.delete(key: "user_role");
    } catch (e) {
      print("Error during logout: $e");
      _error = "Failed to logout: $e";
      notifyListeners();
    }
  }

  void navigateToWallet() {
    print("Wallet clicked");
    // Implement wallet navigation
  }

  void navigateToSettings() {
    print("Settings clicked");
    // Implement settings navigation
  }

  void navigateToProfile() {
    print("Profile clicked");
    // Implement profile navigation
  }
}
