import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  static const String baseUrl = 'http://localhost:3000/api/auth';

  Map<String, dynamic>? _user;
  String? _token;
  bool _isReady = false;
  bool _hasSeenGetStarted = false;
  bool _hasCompletedOnboarding = false;

  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null;
  bool get isReady => _isReady;
  bool get hasSeenGetStarted => _hasSeenGetStarted;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  String get displayName => _user?['user_metadata']?['full_name']?.toString() ?? _user?['email']?.toString() ?? 'Student';

  AuthService() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    _token = prefs.getString('token');
    _hasSeenGetStarted = prefs.getBool('has_seen_get_started') ?? false;
    _hasCompletedOnboarding = prefs.getBool('has_completed_onboarding') ?? false;

    if (userStr != null) {
      _user = json.decode(userStr) as Map<String, dynamic>;
    }

    _isReady = true;
    notifyListeners();
  }

  Future<void> completeGetStarted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_get_started', true);
    _hasSeenGetStarted = true;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);
    _hasCompletedOnboarding = true;
    notifyListeners();
  }

  Future<bool> login(String email, String password, {bool skipOnboarding = true}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email.trim(), 'password': password}),
      );

      if (response.statusCode != 200) return false;

      final data = json.decode(response.body) as Map<String, dynamic>;
      _user = Map<String, dynamic>.from(data['user'] as Map);
      _token = data['session']?['access_token']?.toString();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', json.encode(_user));
      if (_token != null) {
        await prefs.setString('token', _token!);
      }


      if (skipOnboarding) {
        await completeOnboarding();
      } else {
        // Reset the flag if we are NOT skipping, to ensure they go through it
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('has_completed_onboarding', false);
        _hasCompletedOnboarding = false;
      }

      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> register(String email, String password, String fullName, String studentId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email.trim(),
          'password': password,
          'full_name': fullName.trim(),
          'student_id': studentId.trim(),
        }),
      );
      return response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await http.post(Uri.parse('$baseUrl/logout'));
    } catch (_) {}

    _user = null;
    _token = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('token');
    notifyListeners();
  }
}
