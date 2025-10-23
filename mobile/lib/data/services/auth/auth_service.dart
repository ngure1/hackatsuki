import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/data/models/user_details.dart';
import 'package:mobile/data/utils.dart';

class AuthService {
  String? _accessToken;
  String? _refreshToken;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  void _saveTokens(Map<String, dynamic> data) {
    _accessToken = data['access_token'];
    _refreshToken = data['refresh_token'];
  }

  void restoreTokens(String accessToken, String refreshToken) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  Future<UserDetails> signupWithEmail({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['access_token'] == null) {
        throw Exception('Signup failed: ${response.body}');
      }
      _saveTokens(data);

      return UserDetails(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: "",
      );
    } else {
      throw Exception('Signup failed: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signin'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      _saveTokens(data);
      print('tokens saved');
    } else {
      throw Exception('Login Failed: ${response.body}');
    }
  }

  Future<UserDetails> loginWithGoogleCode(String code) async {
    final response = await http.get(
      Uri.parse('$baseUrl/oauth/redirect?code=$code'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _saveTokens(data);
      return UserDetails.fromJson(data['user']);
    } else {
      throw Exception("Google login failed: ${response.body}");
    }
  }

  Future<void> logout() async {
    if (_accessToken == null) return;

    final response = await http.post(
      Uri.parse('$baseUrl/auth/logout/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_accessToken",
      },
    );

    if (response.statusCode == 200) {
      _accessToken = null;
      _refreshToken = null;
    } else {
      throw Exception("Logout failed: ${response.body}");
    }
  }

  Future<void> refreshAuthToken() async {
    if (_refreshToken == null) {
      throw Exception("No refresh token available");
    }

    final response = await http.post(
      Uri.parse("$baseUrl/auth/refresh/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refreshToken": _refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _saveTokens(data);
    } else {
      throw Exception("Token refresh failed: ${response.body}");
    }
  }

  // Authenticated GET
  Future<http.Response> get(String endpoint) async {
    if (_accessToken == null) {
      throw Exception('Not authenticated');
    }
    return await http.get(
      Uri.parse(endpoint),
      headers: {"Authorization": "Bearer $_accessToken"},
    );
  }

  //Authenticated POST
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    if (_accessToken == null) {
      throw Exception("Not authenticated");
    }
    return await http.post(
      Uri.parse(endpoint),
      headers: {
        "Authorization": "Bearer $_accessToken",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );
  }
}
