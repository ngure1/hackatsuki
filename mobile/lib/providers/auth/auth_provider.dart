import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:mobile/data/models/user_details.dart';
import 'package:mobile/data/services/auth/auth_service.dart';
import 'package:mobile/data/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final _storage = const FlutterSecureStorage();

  UserDetails? _user;
  bool _isLoading = false;

  String? _tempPhoneNumber;

  AuthProvider(this._authService);

  UserDetails? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;

  void savePhoneNumber(String? phoneNumber) {
    _tempPhoneNumber = phoneNumber;

    notifyListeners();
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonUser = prefs.getString('user');
    final accessToken = await _storage.read(key: 'accessToken');
    final refreshToken = await _storage.read(key: 'refreshToken');

    if (jsonUser != null && accessToken != null && refreshToken != null) {
      _user = UserDetails.fromJson(jsonDecode(jsonUser));
      _authService.restoreTokens(accessToken, refreshToken);
    }

    notifyListeners();
  }

  Future<void> _saveUser(UserDetails user) async {
    final mergedUser = user.copyWith(
      phoneNumber: _tempPhoneNumber ?? user.phoneNumber,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));

    if (_authService.refreshToken != null) {
      await _storage.write(key: 'accessToken', value: _authService.accessToken);
    }
    if (_authService.refreshToken != null) {
      await _storage.write(
        key: 'refreshToken',
        value: _authService.refreshToken,
      );
    }

    _user = mergedUser;

    _tempPhoneNumber = null;

    notifyListeners();
  }

  Future<void> signup({
  required String firstName,
  required String lastName,
  required String email,
  required String password,
}) async {
  _isLoading = true;
  notifyListeners();

  try {
    final user = await _authService.signupWithEmail(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
    );
    await _saveUser(user);
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}




  Future<void> loginWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.loginWithEmail(email, password);
      await _saveUser(user);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final redirectUrl = await FlutterWebAuth2.authenticate(
        url: '$baseUrl/oauth/google?redirect_uri=aigrowapp://auth',   
        callbackUrlScheme: 'aigrowapp',  
      );

      final code = Uri.parse(redirectUrl).queryParameters['code'];
      if (code == null) throw Exception('Authorization code not returned');

      final user = await _authService.loginWithGoogleCode(code);
      await _saveUser(user);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  
  Future<void> refreshToken() async {
    try {
      await _authService.refreshAuthToken();

      if (_authService.accessToken != null) {
        await _storage.write(
          key: 'accessToken',
          value: _authService.accessToken,
        );
      }
      if (_authService.refreshToken != null) {
        await _storage.write(
          key: 'refreshToken',
          value: _authService.refreshToken,
        );
      }
    } catch (e) {
      await logout();
    }
  }

  Future<void> logout() async {
    await _authService.logout();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("user");

    await _storage.delete(key: "accessToken");
    await _storage.delete(key: "refreshToken");

    _user = null;
    notifyListeners();
  }
}
