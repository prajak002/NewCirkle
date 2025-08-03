import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'cognito_service.dart';

class AuthService {
  static const String baseUrl = 'https://kiis0e7lfj.execute-api.ap-south-1.amazonaws.com/uat';
  static const storage = FlutterSecureStorage();
  
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Cognito service for AWS authentication
  final CognitoService _cognitoService = CognitoService();

  // Current user information
  User? get currentUser => _cognitoService.currentUser;
  String? get accessToken => _cognitoService.accessToken;
  bool get isLoggedIn => _cognitoService.isLoggedIn;
  
  // User role getters
  bool get isStallVendor => _cognitoService.isStallVendor;
  bool get isTopUpUser => _cognitoService.isTopUpUser;
  bool get isAdmin => _cognitoService.isAdmin;

  // Login with username and password using AWS Cognito
  Future<bool> login(String username, String password) async {
    try {
      // Use Cognito service to authenticate
      final success = await _cognitoService.login(username, password);
      
      if (success) {
        // Also store username for future reference
        await storage.write(key: 'username', value: username);
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  // Check if the user is logged in from stored tokens
  Future<bool> isAuthenticated() async {
    return await _cognitoService.isAuthenticated();
  }

  // Logout user
  Future<void> logout() async {
    await _cognitoService.logout();
  }

  // Make authenticated API calls with the AWS Cognito token
  Future<Map<String, dynamic>?> callApi(
    String endpoint,
    {
      Map<String, dynamic>? body,
      String method = 'GET',
    }
  ) async {
    try {
      if (!await isAuthenticated()) {
        throw Exception('Not authenticated');
      }
      
      final token = accessToken;
      if (token == null) {
        throw Exception('No access token available');
      }
      
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      
      http.Response response;
      
      switch (method.toUpperCase()) {
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'GET':
        default:
          response = await http.get(uri, headers: headers);
          break;
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        debugPrint('API error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error calling API: $e');
      return null;
    }
  }
}
