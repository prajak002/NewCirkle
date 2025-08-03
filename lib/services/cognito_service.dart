import 'dart:convert';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class CognitoService {
  static const String _userPoolId = 'ap-south-1_QntFxqDq4';
  static const String _clientId = '74f0rjc0bhpvhlvgsofngb5rf';
  static const storage = FlutterSecureStorage();
  
  // Singleton pattern
  static final CognitoService _instance = CognitoService._internal();
  factory CognitoService() => _instance;
  CognitoService._internal();

  final _userPool = CognitoUserPool(
    _userPoolId,
    _clientId,
  );
  
  CognitoUser? _cognitoUser;
  CognitoUserSession? _session;
  User? _currentUser;

  User? get currentUser => _currentUser;
  String? get accessToken => _session?.accessToken.jwtToken;
  String? get refreshToken => _session?.refreshToken?.token;
  bool get isLoggedIn => _session != null;
  
  // User role getters
  bool get isStallVendor => _currentUser?.role == UserRole.stallVendor;
  bool get isTopUpUser => _currentUser?.role == UserRole.topUpCounter;
  bool get isAdmin => _currentUser?.role == UserRole.admin;

  // Login with username and password
  Future<bool> login(String username, String password) async {
    try {
      _cognitoUser = CognitoUser(username, _userPool);
      final authDetails = AuthenticationDetails(
        username: username,
        password: password,
      );
      
      _session = await _cognitoUser!.authenticateUser(authDetails);
      
      if (_session != null) {
        // Store tokens securely
        await storage.write(key: 'accessToken', value: _session!.accessToken.jwtToken);
        await storage.write(key: 'refreshToken', value: _session!.refreshToken?.token);
        
        // Extract user info from ID token
        final idToken = _session!.idToken.jwtToken;
        final payload = parseJwt(idToken);
        
        // Create user object from token data
        _currentUser = User(
          username: username,
          role: _determineUserRole(payload),
        );
        
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Cognito login error: $e');
      return false;
    }
  }

  // Parse JWT token to extract user claims
  Map<String, dynamic> parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token');
    }

    final payload = parts[1];
    var normalized = base64Url.normalize(payload);
    var resp = utf8.decode(base64Url.decode(normalized));
    final payloadMap = json.decode(resp);
    return payloadMap;
  }

  // Determine user role based on token claims
  UserRole _determineUserRole(Map<String, dynamic> payload) {
    // Check 'cognito:groups' or custom attribute for role information
    if (payload.containsKey('cognito:groups')) {
      final groups = payload['cognito:groups'];
      if (groups is List) {
        for (var group in groups) {
          if (group.toString().toLowerCase().contains('admin')) {
            return UserRole.admin;
          } else if (group.toString().toLowerCase().contains('topup')) {
            return UserRole.topUpCounter;
          } else if (group.toString().toLowerCase().contains('stall')) {
            return UserRole.stallVendor;
          }
        }
      }
    }
    
    // Check custom attributes
    if (payload.containsKey('custom:role')) {
      final role = payload['custom:role'].toString().toLowerCase();
      if (role.contains('admin')) {
        return UserRole.admin;
      } else if (role.contains('topup')) {
        return UserRole.topUpCounter;
      } else if (role.contains('stall')) {
        return UserRole.stallVendor;
      }
    }
    
    return UserRole.stallVendor; // Default role
  }

  // Check if the user is logged in from stored tokens
  Future<bool> isAuthenticated() async {
    try {
      final storedAccessToken = await storage.read(key: 'accessToken');
      final storedRefreshToken = await storage.read(key: 'refreshToken');
      
      if (storedAccessToken == null || storedRefreshToken == null) {
        return false;
      }
      
      // If we have tokens but no active session, try to recreate the session
      if (_session == null) {
        // Get the username from the stored token or local storage
        final username = await storage.read(key: 'username');
        if (username == null) {
          return false;
        }
        
        _cognitoUser = CognitoUser(username, _userPool);
        
        // Create the session from tokens
        _session = CognitoUserSession(
          CognitoIdToken(storedAccessToken),
          CognitoAccessToken(storedAccessToken),
          refreshToken: CognitoRefreshToken(storedRefreshToken),
        );
        
        // Validate the token and refresh if needed
        if (await _refreshSessionIfNeeded()) {
          return true;
        }
      }
      
      return _session != null;
    } catch (e) {
      debugPrint('Error checking authentication: $e');
      return false;
    }
  }
  
  // Refresh the session if the token is expired
  Future<bool> _refreshSessionIfNeeded() async {
    try {
      if (_session == null || _cognitoUser == null) {
        return false;
      }
      
      if (!_session!.isValid()) {
        _session = await _cognitoUser!.refreshSession(_session!.refreshToken!);
        
        if (_session != null) {
          // Update stored tokens
          await storage.write(key: 'accessToken', value: _session!.accessToken.jwtToken);
          await storage.write(key: 'refreshToken', value: _session!.refreshToken?.token);
          return true;
        }
        return false;
      }
      
      return true;
    } catch (e) {
      debugPrint('Error refreshing session: $e');
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      if (_cognitoUser != null) {
        await _cognitoUser!.signOut();
      }
    } catch (e) {
      debugPrint('Error during logout: $e');
    } finally {
      _cognitoUser = null;
      _session = null;
      _currentUser = null;
      
      // Clear stored tokens
      await storage.delete(key: 'accessToken');
      await storage.delete(key: 'refreshToken');
      await storage.delete(key: 'username');
    }
  }
}
