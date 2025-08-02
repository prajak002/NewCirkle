import 'package:flutter/services.dart';

class RazorpayNativeSDK {
  static const MethodChannel _channel =
      MethodChannel('com.example.cirmle_rfid_pos/razorpay_pos');

  /// Initialize the Razorpay SDK
  static Future<Map<String, dynamic>> initializeSDK({
    required String appKey,
    required String username,
    String mode = 'DEMO',
    bool prepareDevice = false,
  }) async {
    try {
      final result = await _channel.invokeMethod('initializeSDK', {
        'appKey': appKey,
        'username': username,
        'mode': mode,
        'prepareDevice': prepareDevice,
      });
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      return {
        'success': false,
        'error': e.code,
        'message': e.message ?? 'Failed to initialize SDK',
      };
    }
  }

  /// Make a general payment (any payment mode)
  static Future<Map<String, dynamic>> makePayment({
    required double amount,
    String? externalRefNumber,
    String? externalRefNumber2,
    String? externalRefNumber3,
    String? externalRefNumber4,
    String? customerName,
    String? customerMobile,
    String? customerEmail,
    double? amountCashback,
    double? amountTip,
  }) async {
    try {
      final result = await _channel.invokeMethod('makePayment', {
        'amount': amount,
        'externalRefNumber': externalRefNumber ?? '',
        'externalRefNumber2': externalRefNumber2 ?? '',
        'externalRefNumber3': externalRefNumber3 ?? '',
        'externalRefNumber4': externalRefNumber4 ?? '',
        'customerName': customerName ?? '',
        'customerMobile': customerMobile ?? '',
        'customerEmail': customerEmail ?? '',
        'amountCashback': amountCashback ?? 0.0,
        'amountTip': amountTip ?? 0.0,
      });
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      return {
        'success': false,
        'error': e.code,
        'message': e.message ?? 'Failed to process payment',
      };
    }
  }

  /// Make a card payment
  static Future<Map<String, dynamic>> cardPayment({
    required double amount,
    String? externalRefNumber,
    String? externalRefNumber2,
    String? customerName,
    String? customerMobile,
    String? customerEmail,
    double? amountCashback,
    double? amountTip,
  }) async {
    try {
      final result = await _channel.invokeMethod('cardPayment', {
        'amount': amount,
        'externalRefNumber': externalRefNumber ?? '',
        'externalRefNumber2': externalRefNumber2 ?? '',
        'customerName': customerName ?? '',
        'customerMobile': customerMobile ?? '',
        'customerEmail': customerEmail ?? '',
        'amountCashback': amountCashback ?? 0.0,
        'amountTip': amountTip ?? 0.0,
      });
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      return {
        'success': false,
        'error': e.code,
        'message': e.message ?? 'Failed to process card payment',
      };
    }
  }

  /// Make a UPI payment
  static Future<Map<String, dynamic>> upiPayment({
    required double amount,
    String? externalRefNumber,
    String? customerName,
    String? customerMobile,
    String? customerEmail,
  }) async {
    try {
      final result = await _channel.invokeMethod('upiPayment', {
        'amount': amount,
        'externalRefNumber': externalRefNumber ?? '',
        'customerName': customerName ?? '',
        'customerMobile': customerMobile ?? '',
        'customerEmail': customerEmail ?? '',
      });
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      return {
        'success': false,
        'error': e.code,
        'message': e.message ?? 'Failed to process UPI payment',
      };
    }
  }

  /// Record a cash payment
  static Future<Map<String, dynamic>> cashPayment({
    required double amount,
    String? externalRefNumber,
    String? customerName,
    String? customerMobile,
    String? customerEmail,
  }) async {
    try {
      final result = await _channel.invokeMethod('cashPayment', {
        'amount': amount,
        'externalRefNumber': externalRefNumber ?? '',
        'customerName': customerName ?? '',
        'customerMobile': customerMobile ?? '',
        'customerEmail': customerEmail ?? '',
      });
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      return {
        'success': false,
        'error': e.code,
        'message': e.message ?? 'Failed to record cash payment',
      };
    }
  }

  /// Void a payment transaction
  static Future<Map<String, dynamic>> voidPayment({
    required String txnId,
  }) async {
    try {
      final result = await _channel.invokeMethod('voidPayment', {
        'txnId': txnId,
      });
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      return {
        'success': false,
        'error': e.code,
        'message': e.message ?? 'Failed to void payment',
      };
    }
  }

  /// Get transaction status
  static Future<Map<String, dynamic>> getTransactionStatus({
    required String txnId,
  }) async {
    try {
      final result = await _channel.invokeMethod('getTransactionStatus', {
        'txnId': txnId,
      });
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      return {
        'success': false,
        'error': e.code,
        'message': e.message ?? 'Failed to get transaction status',
      };
    }
  }

  /// Print receipt for a transaction
  static Future<Map<String, dynamic>> printReceipt({
    required String txnId,
  }) async {
    try {
      final result = await _channel.invokeMethod('printReceipt', {
        'txnId': txnId,
      });
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      return {
        'success': false,
        'error': e.code,
        'message': e.message ?? 'Failed to print receipt',
      };
    }
  }

  /// Close the SDK
  static Future<Map<String, dynamic>> closeSDK() async {
    try {
      final result = await _channel.invokeMethod('closeSDK');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      return {
        'success': false,
        'error': e.code,
        'message': e.message ?? 'Failed to close SDK',
      };
    }
  }
}
