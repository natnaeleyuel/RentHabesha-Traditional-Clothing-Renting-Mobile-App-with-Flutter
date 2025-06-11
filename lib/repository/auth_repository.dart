import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final http.Client httpClient;
  final SharedPreferences prefs;
  final String baseUrl;

  AuthRepository({
    required this.httpClient,
    required this.prefs,
    required this.baseUrl,
  });

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await httpClient.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final token = responseData['token'];
      print('Received Token: $token');
      final user = responseData['user'];
      print('Received User: $user');
      await _saveAuthData({'token': token, 'user': user});
      final storedToken = prefs.getString('auth_token');
      print('Stored Token: $storedToken');
      return responseData;
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Login failed');
    }
  }

  Future<void> _saveAuthData(Map<String, dynamic> authData) async {
    await prefs.setString('auth_token', authData['token']);
    await prefs.setString('user_data', jsonEncode(authData['user']));
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final userData = prefs.getString('user_data');
    return userData != null ? jsonDecode(userData) : null;
  }

  Future<String?> getCurrentUserId() async {
    try {
      final userData = prefs.getString('user_data');
      return userData != null ? jsonDecode(userData)['id'] : null;
    } catch (e) {
      debugPrint('Error getting user ID: $e');
      return null;
    }
  }

  Future<String?> getToken() async {
    return prefs.getString('auth_token');
  }

  Future<bool> logout() async {
    try {
      final token = prefs.getString('auth_token');
      if (token == null) {
        await prefs.remove('auth_token');
        await prefs.remove('user_data');
        return true;
      }

      final response = await httpClient.post(
        Uri.parse('$baseUrl/api/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      await prefs.remove('auth_token');
      await prefs.remove('user_data');

      if (response.statusCode == 200) {
        debugPrint('Logout successful');
        return true;
      } else {
        debugPrint('Logout failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error logging out: $e');
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      return true;
    }
  }

  Future<bool> isLoggedIn() async {
    return prefs.containsKey('auth_token');
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      final token = prefs.getString('auth_token');
      final userData = prefs.getString('user_data');
      final userId = jsonDecode(userData!)['id'];

      if (token == null || userId == null) {
        throw Exception('Authentication required');
      }

      if (newPassword.length < 8) {
        throw Exception('Password must be at least 8 characters');
      }

      final response = await httpClient.post(
        Uri.parse('$baseUrl/api/auth/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      debugPrint('Change Password Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        await prefs.remove('auth_token');
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Password change failed');
      }
    } catch (e) {
      debugPrint('Password change error: $e');
      rethrow;
    }
  }

  Future<bool> deleteAccount(String currentPassword) async {
    try {
      final token = prefs.getString('auth_token');
      debugPrint('Delete Account Token: $token');
      if (token == null) throw Exception('Not authenticated');
      final userData = prefs.getString('user_data');
      final userId = jsonDecode(userData!)['id'];
      debugPrint('Delete Account User ID: $userId');

      if (userId == null) throw Exception('User ID not found');

      final response = await httpClient.post(
        Uri.parse('$baseUrl/api/auth/delete-user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'password': currentPassword,
          'userId': userId,
        }),
      );

      debugPrint('Delete Account Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        await prefs.remove('auth_token');
        await prefs.remove('user_data');
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Account deletion failed');
      }
    } catch (e) {
      debugPrint('Account deletion error: $e');
      rethrow;
    }
  }
}







