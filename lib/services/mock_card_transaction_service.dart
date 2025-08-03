import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

/// Model classes
class CardBalance {
  final String cardUid;
  final double balance;
  final DateTime lastUpdated;
  final String currency;

  CardBalance({
    required this.cardUid,
    required this.balance,
    required this.lastUpdated,
    this.currency = 'INR',
  });

  Map<String, dynamic> toJson() => {
    'cardUid': cardUid,
    'balance': balance,
    'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    'currency': currency,
  };

  factory CardBalance.fromJson(Map<String, dynamic> json) {
    return CardBalance(
      cardUid: json['cardUid'],
      balance: json['balance'].toDouble(),
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(json['lastUpdated']),
      currency: json['currency'] ?? 'INR',
    );
  }
}

class CardPaymentRequest {
  final String cardId;
  final double amount;
  final String merchantId;
  final String terminalId;

  CardPaymentRequest({
    required this.cardId,
    required this.amount,
    required this.merchantId,
    required this.terminalId,
  });
}

class CardTransaction {
  final String transactionId;
  final String cardUid;
  final double amount;
  final DateTime timestamp;
  final String status;
  final String merchantId;
  final Map<String, dynamic> metadata;

  CardTransaction({
    required this.transactionId,
    required this.cardUid,
    required this.amount,
    required this.timestamp,
    required this.status,
    required this.merchantId,
    this.metadata = const {},
  });
}

/// Mock implementation of Card Transaction Service
class CardTransactionService {
  // In-memory database for testing
  static final Map<String, CardBalance> _cardBalances = {};
  static final List<CardTransaction> _transactions = [];
  static final Random _random = Random();
  
  // Configurable settings
  final bool simulateNetworkDelay;
  final double failureRate;
  
  // Singleton pattern
  static final CardTransactionService _instance = CardTransactionService._internal();
  factory CardTransactionService() => _instance;
  
  CardTransactionService._internal({
    this.simulateNetworkDelay = true,
    this.failureRate = 0.05, // 5% failure rate
  }) {
    // Initialize with some sample data
    _initializeSampleData();
  }

  /// Create some sample data for testing
  void _initializeSampleData() {
    // Sample card balances
    _cardBalances['11:22:33:44'] = CardBalance(
      cardUid: '11:22:33:44',
      balance: 500.0,
      lastUpdated: DateTime.now().subtract(Duration(days: 1)),
    );
    
    _cardBalances['AA:BB:CC:DD'] = CardBalance(
      cardUid: 'AA:BB:CC:DD',
      balance: 1000.0,
      lastUpdated: DateTime.now().subtract(Duration(hours: 3)),
    );
    
    // Sample transactions
    _transactions.add(
      CardTransaction(
        transactionId: 'TXN_001',
        cardUid: '11:22:33:44',
        amount: 50.0,
        timestamp: DateTime.now().subtract(Duration(days: 2)),
        status: 'success',
        merchantId: 'MERCHANT_01',
      ),
    );
    
    _transactions.add(
      CardTransaction(
        transactionId: 'TXN_002',
        cardUid: 'AA:BB:CC:DD',
        amount: 150.0,
        timestamp: DateTime.now().subtract(Duration(hours: 5)),
        status: 'success',
        merchantId: 'MERCHANT_02',
      ),
    );
  }
  
  /// Simulate network delay if enabled
  Future<void> _simulateNetworkDelay() async {
    if (simulateNetworkDelay) {
      await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(700)));
    }
  }
  
  /// Simulate random failures
  bool _shouldFail() {
    return _random.nextDouble() < failureRate;
  }

  /// Get card balance for a given card UID
  Future<CardBalance> getCardBalance(String cardUid) async {
    await _simulateNetworkDelay();
    
    if (_shouldFail()) {
      throw Exception('Failed to retrieve card balance');
    }
    
    // If the card doesn't exist in our mock DB, create it with a random balance
    if (!_cardBalances.containsKey(cardUid)) {
      _cardBalances[cardUid] = CardBalance(
        cardUid: cardUid,
        balance: 100.0 + _random.nextDouble() * 900.0, // Random balance between 100 and 1000
        lastUpdated: DateTime.now().subtract(Duration(days: _random.nextInt(7))),
      );
    }
    
    return _cardBalances[cardUid]!;
  }
  
  /// Process a payment using the card
  Future<CardTransaction> processCardPayment(CardPaymentRequest request) async {
    await _simulateNetworkDelay();
    
    if (_shouldFail()) {
      throw Exception('Payment processing failed');
    }
    
    // Fetch current balance
    final cardBalance = await getCardBalance(request.cardId);
    
    // Check if there's enough balance
    if (cardBalance.balance < request.amount) {
      throw Exception('Insufficient balance');
    }
    
    // Update balance
    _cardBalances[request.cardId] = CardBalance(
      cardUid: request.cardId,
      balance: cardBalance.balance - request.amount,
      lastUpdated: DateTime.now(),
      currency: cardBalance.currency,
    );
    
    // Create transaction record
    final transaction = CardTransaction(
      transactionId: 'TXN_${DateTime.now().millisecondsSinceEpoch}',
      cardUid: request.cardId,
      amount: request.amount,
      timestamp: DateTime.now(),
      status: 'success',
      merchantId: request.merchantId,
      metadata: {'terminalId': request.terminalId},
    );
    
    // Add to transaction history
    _transactions.add(transaction);
    
    return transaction;
  }
  
  /// Add funds to a card (top-up)
  Future<CardTransaction> addFunds({
    required String cardUid,
    required double amount,
    required String paymentMethod,
  }) async {
    await _simulateNetworkDelay();
    
    if (_shouldFail()) {
      throw Exception('Failed to add funds to card');
    }
    
    // Fetch current balance
    final cardBalance = await getCardBalance(cardUid);
    
    // Update balance
    _cardBalances[cardUid] = CardBalance(
      cardUid: cardUid,
      balance: cardBalance.balance + amount,
      lastUpdated: DateTime.now(),
      currency: cardBalance.currency,
    );
    
    // Create transaction record
    final transaction = CardTransaction(
      transactionId: 'TXN_TOPUP_${DateTime.now().millisecondsSinceEpoch}',
      cardUid: cardUid,
      amount: amount,
      timestamp: DateTime.now(),
      status: 'success',
      merchantId: 'SELF_TOPUP',
      metadata: {'paymentMethod': paymentMethod},
    );
    
    // Add to transaction history
    _transactions.add(transaction);
    
    return transaction;
  }
  
  /// Get transaction history for a card
  Future<List<CardTransaction>> getCardTransactions(String cardUid) async {
    await _simulateNetworkDelay();
    
    if (_shouldFail()) {
      throw Exception('Failed to retrieve transaction history');
    }
    
    // Filter transactions for this card
    return _transactions
        .where((transaction) => transaction.cardUid == cardUid)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort by date descending
  }
  
  /// Register a new card
  Future<bool> registerCard({
    required String cardUid,
    required String customerId,
    double initialBalance = 0.0,
  }) async {
    await _simulateNetworkDelay();
    
    if (_shouldFail()) {
      throw Exception('Failed to register card');
    }
    
    // Create new card with initial balance
    _cardBalances[cardUid] = CardBalance(
      cardUid: cardUid,
      balance: initialBalance,
      lastUpdated: DateTime.now(),
    );
    
    // If initial balance > 0, create a top-up transaction
    if (initialBalance > 0) {
      _transactions.add(
        CardTransaction(
          transactionId: 'TXN_INIT_${DateTime.now().millisecondsSinceEpoch}',
          cardUid: cardUid,
          amount: initialBalance,
          timestamp: DateTime.now(),
          status: 'success',
          merchantId: 'INITIAL_LOAD',
          metadata: {'customerId': customerId},
        ),
      );
    }
    
    return true;
  }
}
