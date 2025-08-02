import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'razorpay_pos_config.dart';
import 'razorpay_pos_models.dart';

enum PaymentResult { success, failed, cancelled, timeout, error }

class PaymentTransaction {
  final String id;
  final PaymentRequest request;
  final PaymentResponse? paymentResponse;
  final StatusResponse? finalStatus;
  final PaymentResult result;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? completedAt;

  PaymentTransaction({
    required this.id,
    required this.request,
    this.paymentResponse,
    this.finalStatus,
    required this.result,
    this.errorMessage,
    required this.createdAt,
    this.completedAt,
  });

  bool get isCompleted =>
      result == PaymentResult.success ||
      result == PaymentResult.failed ||
      result == PaymentResult.cancelled ||
      result == PaymentResult.timeout;

  bool get isSuccessful => result == PaymentResult.success;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request': request.toJson(),
      'paymentResponse': paymentResponse?.toJson(),
      'finalStatus': finalStatus != null ? _statusResponseToJson(finalStatus!) : null,
      'result': result.toString(),
      'errorMessage': errorMessage,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> _statusResponseToJson(StatusResponse status) {
    return {
      'success': status.success,
      'messageCode': status.messageCode,
      'message': status.message,
      'status': status.status,
      'txnId': status.txnId,
      'amount': status.amount,
      'formattedPan': status.formattedPan,
      'paymentCardBrand': status.paymentCardBrand,
      'authCode': status.authCode,
      'receiptUrl': status.receiptUrl,
      'errorCode': status.errorCode,
      'errorMessage': status.errorMessage,
    };
  }
}

class RazorpayPOSService {
  static final RazorpayPOSService _instance = RazorpayPOSService._internal();
  factory RazorpayPOSService() => _instance;
  RazorpayPOSService._internal();

  final Dio _dio = Dio();
  final Uuid _uuid = const Uuid();
  final Map<String, PaymentTransaction> _activeTransactions = {};
  final Map<String, Timer> _statusCheckTimers = {};

  // Event streams
  final StreamController<PaymentTransaction> _transactionController = 
      StreamController<PaymentTransaction>.broadcast();
  
  Stream<PaymentTransaction> get transactionStream => _transactionController.stream;

  void _initializeDio() {
    _dio.options = BaseOptions(
      connectTimeout: Duration(seconds: RazorpayPOSConfig.apiTimeout),
      receiveTimeout: Duration(seconds: RazorpayPOSConfig.apiTimeout),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    // Add logging interceptor for debugging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) => print('[RazorpayPOS] $object'),
    ));
  }

  Future<PaymentTransaction> initiatePayment({
    required double amount,
    required String deviceId,
    required String deviceType,
    required String paymentMode,
    String? externalRefNumber,
    String? description,
    String? customerMobile,
    String? customerEmail,
    String? customerName,
    String? accountLabel,
    String? username,
    double? amountCashBack,
    double? amountAdditional,
    Map<String, dynamic>? additionalData,
  }) async {
    _initializeDio();

    // Generate unique reference number if not provided
    externalRefNumber ??= 'TXN_${_uuid.v4().substring(0, 8).toUpperCase()}';
    
    final transactionId = _uuid.v4();
    
    final request = PaymentRequest(
      appKey: RazorpayPOSConfig.appKey,
      username: username ?? RazorpayPOSConfig.defaultUsername,
      amount: amount,
      deviceId: deviceId,
      deviceType: deviceType,
      mode: paymentMode,
      externalRefNumber: externalRefNumber,
      description: description,
      customerMobileNumber: customerMobile,
      customerEmail: customerEmail,
      customerName: customerName,
      accountLabel: accountLabel,
      amountCashBack: amountCashBack,
      amountAdditional: amountAdditional,
      additionalData: additionalData,
    );

    try {
      // Send payment request
      final response = await _dio.post(
        RazorpayPOSConfig.payUrl,
        data: request.toJson(),
      );

      final paymentResponse = PaymentResponse.fromJson(response.data);

      PaymentTransaction transaction;

      if (paymentResponse.success && paymentResponse.p2pRequestId != null) {
        // Payment request initiated successfully
        transaction = PaymentTransaction(
          id: transactionId,
          request: request,
          paymentResponse: paymentResponse,
          result: PaymentResult.success,
          createdAt: DateTime.now(),
        );

        _activeTransactions[transactionId] = transaction;
        _transactionController.add(transaction);

        // Start status monitoring
        _startStatusMonitoring(transactionId, paymentResponse.p2pRequestId!);

        return transaction;
      } else {
        // Payment request failed
        transaction = PaymentTransaction(
          id: transactionId,
          request: request,
          paymentResponse: paymentResponse,
          result: PaymentResult.error,
          errorMessage: paymentResponse.errorMessage ?? 'Payment initiation failed',
          createdAt: DateTime.now(),
          completedAt: DateTime.now(),
        );

        _transactionController.add(transaction);
        return transaction;
      }
    } catch (e) {
      final transaction = PaymentTransaction(
        id: transactionId,
        request: request,
        result: PaymentResult.error,
        errorMessage: 'Network error: ${e.toString()}',
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
      );

      _transactionController.add(transaction);
      return transaction;
    }
  }

  void _startStatusMonitoring(String transactionId, String p2pRequestId) {
    // Wait initial delay before first status check
    Timer(Duration(seconds: RazorpayPOSConfig.initialStatusCheckDelay), () {
      _performStatusCheck(transactionId, p2pRequestId);
    });

    // Set overall timeout
    Timer(Duration(seconds: RazorpayPOSConfig.maxStatusCheckDuration), () {
      _handleTransactionTimeout(transactionId, p2pRequestId);
    });
  }

  void _performStatusCheck(String transactionId, String p2pRequestId) async {
    if (!_activeTransactions.containsKey(transactionId)) return;

    try {
      final statusRequest = StatusRequest(
        username: RazorpayPOSConfig.defaultUsername,
        appKey: RazorpayPOSConfig.appKey,
        origP2pRequestId: p2pRequestId,
      );

      final response = await _dio.post(
        RazorpayPOSConfig.statusUrl,
        data: statusRequest.toJson(),
      );

      final statusResponse = StatusResponse.fromJson(response.data);
      
      if (_shouldContinueStatusCheck(statusResponse)) {
        // Schedule next status check
        _statusCheckTimers[transactionId] = Timer(
          Duration(seconds: RazorpayPOSConfig.statusCheckInterval),
          () => _performStatusCheck(transactionId, p2pRequestId),
        );
      } else {
        // Transaction completed
        _completeTransaction(transactionId, statusResponse);
      }
    } catch (e) {
      print('[RazorpayPOS] Status check error: $e');
      // Continue checking unless transaction is completed
      if (_activeTransactions.containsKey(transactionId)) {
        _statusCheckTimers[transactionId] = Timer(
          Duration(seconds: RazorpayPOSConfig.statusCheckInterval),
          () => _performStatusCheck(transactionId, p2pRequestId),
        );
      }
    }
  }

  bool _shouldContinueStatusCheck(StatusResponse status) {
    // Continue checking if device received but transaction not done
    if (status.messageCode == RazorpayPOSConfig.messageCodeDeviceReceived) {
      return true;
    }
    
    // Continue checking if queued
    if (status.messageCode == RazorpayPOSConfig.messageCodeStatusQueued) {
      return true;
    }

    // Stop checking if transaction done, cancelled, or expired
    if (status.messageCode == RazorpayPOSConfig.messageCodeDeviceTxnDone ||
        status.messageCode == RazorpayPOSConfig.messageCodeDeviceCanceled ||
        status.messageCode == RazorpayPOSConfig.messageCodeCanceledFromExternal ||
        status.messageCode == RazorpayPOSConfig.messageCodeStatusExpired) {
      return false;
    }

    return true;
  }

  void _completeTransaction(String transactionId, StatusResponse statusResponse) {
    final transaction = _activeTransactions[transactionId];
    if (transaction == null) return;

    PaymentResult result;
    String? errorMessage;

    if (statusResponse.status == RazorpayPOSConfig.statusAuthorized) {
      result = PaymentResult.success;
    } else if (statusResponse.status == RazorpayPOSConfig.statusFailed) {
      result = PaymentResult.failed;
      errorMessage = statusResponse.errorMessage ?? 'Transaction failed';
    } else if (statusResponse.status == RazorpayPOSConfig.statusExpired) {
      result = PaymentResult.timeout;
      errorMessage = 'Transaction expired';
    } else if (statusResponse.messageCode == RazorpayPOSConfig.messageCodeDeviceCanceled ||
               statusResponse.messageCode == RazorpayPOSConfig.messageCodeCanceledFromExternal) {
      result = PaymentResult.cancelled;
      errorMessage = 'Transaction cancelled';
    } else {
      result = PaymentResult.error;
      errorMessage = statusResponse.errorMessage ?? 'Unknown error';
    }

    final completedTransaction = PaymentTransaction(
      id: transaction.id,
      request: transaction.request,
      paymentResponse: transaction.paymentResponse,
      finalStatus: statusResponse,
      result: result,
      errorMessage: errorMessage,
      createdAt: transaction.createdAt,
      completedAt: DateTime.now(),
    );

    _activeTransactions.remove(transactionId);
    _statusCheckTimers[transactionId]?.cancel();
    _statusCheckTimers.remove(transactionId);

    _transactionController.add(completedTransaction);
  }

  void _handleTransactionTimeout(String transactionId, String p2pRequestId) async {
    if (!_activeTransactions.containsKey(transactionId)) return;

    try {
      // Try to cancel the transaction
      await cancelPayment(transactionId, p2pRequestId);
    } catch (e) {
      print('[RazorpayPOS] Failed to cancel timed out transaction: $e');
    }

    final transaction = _activeTransactions[transactionId];
    if (transaction != null) {
      final timeoutTransaction = PaymentTransaction(
        id: transaction.id,
        request: transaction.request,
        paymentResponse: transaction.paymentResponse,
        result: PaymentResult.timeout,
        errorMessage: 'Transaction timed out after ${RazorpayPOSConfig.maxStatusCheckDuration} seconds',
        createdAt: transaction.createdAt,
        completedAt: DateTime.now(),
      );

      _activeTransactions.remove(transactionId);
      _statusCheckTimers[transactionId]?.cancel();
      _statusCheckTimers.remove(transactionId);

      _transactionController.add(timeoutTransaction);
    }
  }

  Future<CancelResponse> cancelPayment(String transactionId, String p2pRequestId) async {
    final transaction = _activeTransactions[transactionId];
    if (transaction == null) {
      throw Exception('Transaction not found');
    }

    try {
      final cancelRequest = CancelRequest(
        username: RazorpayPOSConfig.defaultUsername,
        appKey: RazorpayPOSConfig.appKey,
        origP2pRequestId: p2pRequestId,
        deviceId: transaction.request.deviceId,
        deviceType: transaction.request.deviceType,
      );

      final response = await _dio.post(
        RazorpayPOSConfig.cancelUrl,
        data: cancelRequest.toJson(),
      );

      final cancelResponse = CancelResponse.fromJson(response.data);

      if (cancelResponse.success) {
        // Remove from active transactions
        _activeTransactions.remove(transactionId);
        _statusCheckTimers[transactionId]?.cancel();
        _statusCheckTimers.remove(transactionId);

        // Create cancelled transaction
        final cancelledTransaction = PaymentTransaction(
          id: transaction.id,
          request: transaction.request,
          paymentResponse: transaction.paymentResponse,
          result: PaymentResult.cancelled,
          errorMessage: 'Transaction cancelled by user',
          createdAt: transaction.createdAt,
          completedAt: DateTime.now(),
        );

        _transactionController.add(cancelledTransaction);
      }

      return cancelResponse;
    } catch (e) {
      throw Exception('Failed to cancel payment: ${e.toString()}');
    }
  }

  Future<StatusResponse> getTransactionStatus(String p2pRequestId) async {
    _initializeDio();

    try {
      final statusRequest = StatusRequest(
        username: RazorpayPOSConfig.defaultUsername,
        appKey: RazorpayPOSConfig.appKey,
        origP2pRequestId: p2pRequestId,
      );

      final response = await _dio.post(
        RazorpayPOSConfig.statusUrl,
        data: statusRequest.toJson(),
      );

      return StatusResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get transaction status: ${e.toString()}');
    }
  }

  // DQR specific method
  Future<PaymentTransaction> initiateDQRPayment({
    required double amount,
    required String deviceId,
    String? externalRefNumber,
    String? description,
    String? customerMobile,
    String? customerEmail,
    String? customerName,
    String? username,
  }) async {
    return initiatePayment(
      amount: amount,
      deviceId: deviceId,
      deviceType: RazorpayPOSConfig.deviceTypeSoundbox,
      paymentMode: RazorpayPOSConfig.paymentModeUPI,
      externalRefNumber: externalRefNumber,
      description: description,
      customerMobile: customerMobile,
      customerEmail: customerEmail,
      customerName: customerName,
      username: username,
    );
  }

  // Helper method to create payment for testing
  Future<PaymentTransaction> createTestPayment({
    required double amount,
    required String deviceId,
    String? paymentMode,
    String? deviceType,
  }) async {
    // For testing, use demo values
    return initiatePayment(
      amount: amount,
      deviceId: deviceId,
      deviceType: deviceType ?? RazorpayPOSConfig.deviceTypeAndroid,
      paymentMode: paymentMode ?? RazorpayPOSConfig.paymentModeCard,
      description: 'Test Payment',
      customerName: 'Test Customer',
      customerEmail: 'test@example.com',
    );
  }

  List<PaymentTransaction> getActiveTransactions() {
    return _activeTransactions.values.toList();
  }

  void dispose() {
    for (final timer in _statusCheckTimers.values) {
      timer.cancel();
    }
    _statusCheckTimers.clear();
    _activeTransactions.clear();
    _transactionController.close();
  }

  // Utility method to validate device ID format
  static bool isValidDeviceId(String deviceId) {
    // Device ID should contain only alphanumeric characters and be at least 8 characters
    return RegExp(r'^[a-zA-Z0-9]{8,}$').hasMatch(deviceId);
  }

  // Get error message for error code
  static String getErrorMessage(String? errorCode) {
    if (errorCode == null) return 'Unknown error';
    return RazorpayPOSConfig.errorCodes[errorCode] ?? 'Unknown error: $errorCode';
  }

  // Check if amount is a test amount
  static bool isTestAmount(double amount) {
    return RazorpayPOSConfig.testAmounts.containsKey(amount);
  }

  // Get test scenario for amount
  static String? getTestScenario(double amount) {
    return RazorpayPOSConfig.testAmounts[amount];
  }
}
