class CardInfo {
  final String uid;
  final String? cardType;
  final String? serialNumber;
  final DateTime detectedAt;
  final Map<String, dynamic>? additionalData;

  CardInfo({
    required this.uid,
    this.cardType,
    this.serialNumber,
    required this.detectedAt,
    this.additionalData,
  });

  factory CardInfo.fromJson(Map<String, dynamic> json) {
    return CardInfo(
      uid: json['uid'],
      cardType: json['cardType'],
      serialNumber: json['serialNumber'],
      detectedAt: DateTime.fromMillisecondsSinceEpoch(json['detectedAt']),
      additionalData: json['additionalData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'cardType': cardType,
      'serialNumber': serialNumber,
      'detectedAt': detectedAt.millisecondsSinceEpoch,
      'additionalData': additionalData,
    };
  }

  @override
  String toString() {
    return 'CardInfo(uid: $uid, cardType: $cardType, detectedAt: $detectedAt)';
  }
}

class CardTransaction {
  final String cardUid;
  final double amount;
  final String transactionId;
  final DateTime timestamp;
  final String status; // 'pending', 'success', 'failed'
  final String? merchantId;
  final String? terminalId;
  final Map<String, dynamic>? metadata;

  CardTransaction({
    required this.cardUid,
    required this.amount,
    required this.transactionId,
    required this.timestamp,
    required this.status,
    this.merchantId,
    this.terminalId,
    this.metadata,
  });

  factory CardTransaction.fromJson(Map<String, dynamic> json) {
    return CardTransaction(
      cardUid: json['cardUid'],
      amount: (json['amount'] as num).toDouble(),
      transactionId: json['transactionId'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      status: json['status'],
      merchantId: json['merchantId'],
      terminalId: json['terminalId'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardUid': cardUid,
      'amount': amount,
      'transactionId': transactionId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'status': status,
      'merchantId': merchantId,
      'terminalId': terminalId,
      'metadata': metadata,
    };
  }
}

class CardBalance {
  final String cardUid;
  final double balance;
  final DateTime lastUpdated;
  final String currency;
  final List<CardTransaction>? recentTransactions;

  CardBalance({
    required this.cardUid,
    required this.balance,
    required this.lastUpdated,
    this.currency = 'INR',
    this.recentTransactions,
  });

  factory CardBalance.fromJson(Map<String, dynamic> json) {
    return CardBalance(
      cardUid: json['cardUid'],
      balance: (json['balance'] as num).toDouble(),
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(json['lastUpdated']),
      currency: json['currency'] ?? 'INR',
      recentTransactions: (json['recentTransactions'] as List?)
          ?.map((e) => CardTransaction.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardUid': cardUid,
      'balance': balance,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
      'currency': currency,
      'recentTransactions': recentTransactions?.map((e) => e.toJson()).toList(),
    };
  }
}
