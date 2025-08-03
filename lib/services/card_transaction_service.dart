import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/card_models.dart';

class CardTransactionService {
  static const String baseUrl = 'https://your-backend-api.com/api'; // Replace with your actual backend URL
  static const Duration timeoutDuration = Duration(seconds: 30);

  /// Process payment using card UID
  static Future<CardTransaction?> processPayment({
    required String cardUid,
    required double amount,
    String? merchantId,
    String? terminalId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final transactionId = 'TXN_${DateTime.now().millisecondsSinceEpoch}';
      
      final requestBody = {
        'cardUid': cardUid,
        'amount': amount,
        'transactionId': transactionId,
        'merchantId': merchantId,
        'terminalId': terminalId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'metadata': metadata,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/card/process-payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_TOKEN', // Replace with actual token
        },
        body: json.encode(requestBody),
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return CardTransaction.fromJson(responseData['transaction']);
        } else {
          print('Payment failed: ${responseData['message']}');
          return null;
        }
      } else {
        print('HTTP Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error processing payment: $e');
      return null;
    }
  }

  /// Get card balance
  static Future<CardBalance?> getCardBalance(String cardUid) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/card/balance/$cardUid'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_TOKEN', // Replace with actual token
        },
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return CardBalance.fromJson(responseData['balance']);
        } else {
          print('Failed to get balance: ${responseData['message']}');
          return null;
        }
      } else {
        print('HTTP Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error getting card balance: $e');
      return null;
    }
  }

  /// Add funds to card
  static Future<bool> addFunds({
    required String cardUid,
    required double amount,
    String? paymentMethod,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final requestBody = {
        'cardUid': cardUid,
        'amount': amount,
        'paymentMethod': paymentMethod ?? 'cash',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'metadata': metadata,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/card/add-funds'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_TOKEN', // Replace with actual token
        },
        body: json.encode(requestBody),
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['success'] == true;
      } else {
        print('HTTP Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error adding funds: $e');
      return false;
    }
  }

  /// Get transaction history
  static Future<List<CardTransaction>?> getTransactionHistory({
    required String cardUid,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/card/transactions/$cardUid?limit=$limit&offset=$offset'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_TOKEN', // Replace with actual token
        },
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final transactions = (responseData['transactions'] as List)
              .map((e) => CardTransaction.fromJson(e))
              .toList();
          return transactions;
        } else {
          print('Failed to get transactions: ${responseData['message']}');
          return null;
        }
      } else {
        print('HTTP Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error getting transaction history: $e');
      return null;
    }
  }

  /// Verify card status
  static Future<bool> verifyCard(String cardUid) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/card/verify/$cardUid'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_TOKEN', // Replace with actual token
        },
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['success'] == true && responseData['valid'] == true;
      } else {
        print('HTTP Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error verifying card: $e');
      return false;
    }
  }

  /// Register new card
  static Future<bool> registerCard({
    required String cardUid,
    String? holderName,
    String? holderPhone,
    String? holderEmail,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final requestBody = {
        'cardUid': cardUid,
        'userId': 'test', // Always use 'test' as userId
        'holderName': holderName,
        'holderPhone': holderPhone,
        'holderEmail': holderEmail,
        'registeredAt': DateTime.now().millisecondsSinceEpoch,
        'metadata': metadata,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/card/register'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_TOKEN', // Replace with actual token
        },
        body: json.encode(requestBody),
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['success'] == true;
      } else {
        print('HTTP Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error registering card: $e');
      return false;
    }
  }

  /// Deactivate card
  static Future<bool> deactivateCard(String cardUid, String reason) async {
    try {
      final requestBody = {
        'cardUid': cardUid,
        'reason': reason,
        'deactivatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/card/deactivate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_TOKEN', // Replace with actual token
        },
        body: json.encode(requestBody),
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['success'] == true;
      } else {
        print('HTTP Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error deactivating card: $e');
      return false;
    }
  }
}
