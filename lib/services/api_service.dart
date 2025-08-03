import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'https://kiis0e7lfj.execute-api.ap-south-1.amazonaws.com/uat';
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final AuthService _authService = AuthService();

  // Create a payment order
  Future<Map<String, dynamic>?> createOrder({
    required int amount,
    String currency = 'INR',
    String? receipt,
    Map<String, String>? notes,
  }) async {
    try {
      // Ensure user is authenticated
      if (!await _authService.isAuthenticated()) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/create-order'),
        headers: _authService.authHeaders,
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
          'receipt': receipt ?? 'receipt_${DateTime.now().millisecondsSinceEpoch}',
          'notes': notes ?? {
            'customer_id': _authService.currentUser?.username ?? 'unknown',
            'product': 'RFID Card Payment'
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      
      debugPrint('Create order failed: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      debugPrint('Create order error: $e');
      return null;
    }
  }

  // Process card top-up
  Future<bool> processCardTopUp({
    required String cardUid,
    required int amount,
    required String transactionId,
  }) async {
    try {
      // This would be implemented based on your backend API
      // For now, it's a placeholder for the card top-up endpoint
      
      final response = await http.post(
        Uri.parse('$baseUrl/card-top-up'),  // Replace with actual endpoint
        headers: _authService.authHeaders,
        body: jsonEncode({
          'cardUid': cardUid,
          'amount': amount,
          'transactionId': transactionId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Process card top-up error: $e');
      return false;
    }
  }

  // Get card balance
  Future<Map<String, dynamic>?> getCardBalance(String cardUid) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/card-balance/$cardUid'),  // Replace with actual endpoint
        headers: _authService.authHeaders,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Get card balance error: $e');
      return null;
    }
  }

  // Get transaction history
  Future<List<Map<String, dynamic>>?> getTransactionHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/my-transactions'),
        headers: _authService.authHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Get transaction history error: $e');
      return null;
    }
  }
}
