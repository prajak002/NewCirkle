import 'dart:async';
import 'package:flutter/material.dart';
import '../services/neptune/neptune_service.dart';
import '../services/mock_card_transaction_service.dart';

class NeptuneMockTestScreen extends StatefulWidget {
  const NeptuneMockTestScreen({Key? key}) : super(key: key);

  @override
  State<NeptuneMockTestScreen> createState() => _NeptuneMockTestScreenState();
}

class _NeptuneMockTestScreenState extends State<NeptuneMockTestScreen> {
  final _amountController = TextEditingController(text: '100.00');
  final _merchantIdController = TextEditingController(text: 'MERCHANT_TEST');
  final _terminalIdController = TextEditingController(text: 'TERM_001');
  
  final NeptuneService _neptuneService = NeptuneService();
  final CardTransactionService _transactionService = CardTransactionService();
  
  bool _isSDKInitialized = false;
  bool _isDetecting = false;
  bool _isProcessing = false;
  
  String _statusMessage = 'Ready to initialize';
  String? _detectedCardUID;
  CardBalance? _cardBalance;
  CardTransaction? _lastTransaction;
  List<CardTransaction>? _transactions;
  
  StreamSubscription? _cardDetectionSubscription;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _cardDetectionSubscription?.cancel();
    _amountController.dispose();
    _merchantIdController.dispose();
    _terminalIdController.dispose();
    _neptuneService.dispose();
    super.dispose();
  }

  // Initialize the Neptune SDK
  Future<void> _initializeSDK() async {
    setState(() {
      _statusMessage = "Initializing Neptune SDK...";
    });

    try {
      final result = await _neptuneService.initialize();
      setState(() {
        _isSDKInitialized = result;
        _statusMessage = result 
            ? "SDK initialized successfully"
            : "Failed to initialize SDK";
      });
    } catch (e) {
      setState(() {
        _isSDKInitialized = false;
        _statusMessage = "Error initializing SDK: ${e.toString()}";
      });
    }
  }

  // Start card detection
  Future<void> _startCardDetection() async {
    if (!_isSDKInitialized) {
      setState(() {
        _statusMessage = "SDK not initialized. Please initialize first.";
      });
      return;
    }

    setState(() {
      _isDetecting = true;
      _detectedCardUID = null;
      _statusMessage = "Waiting for card...";
    });

    try {
      _cardDetectionSubscription = _neptuneService.detectCard().listen(
        (cardUID) {
          if (cardUID != null && cardUID.isNotEmpty) {
            setState(() {
              _detectedCardUID = cardUID;
              _statusMessage = "Card detected: $cardUID";
              _isDetecting = false;
            });
            _cardDetectionSubscription?.cancel();
            _readCardBalance(cardUID);
          }
        },
        onError: (error) {
          setState(() {
            _statusMessage = "Error detecting card: ${error.toString()}";
            _isDetecting = false;
          });
          _cardDetectionSubscription?.cancel();
        }
      );
      
      await _neptuneService.startCardDetection();
    } catch (e) {
      setState(() {
        _statusMessage = "Error starting card detection: ${e.toString()}";
        _isDetecting = false;
      });
    }
  }

  // Read single card manually
  Future<void> _readCardManually() async {
    if (!_isSDKInitialized) {
      setState(() {
        _statusMessage = "SDK not initialized. Please initialize first.";
      });
      return;
    }

    setState(() {
      _isDetecting = true;
      _detectedCardUID = null;
      _statusMessage = "Reading card...";
    });

    try {
      final cardUID = await _neptuneService.readCardUID();
      
      setState(() {
        _isDetecting = false;
        
        if (cardUID != null) {
          _detectedCardUID = cardUID;
          _statusMessage = "Card read: $cardUID";
          
          // Get card balance
          _readCardBalance(cardUID);
        } else {
          _statusMessage = "Failed to read card";
        }
      });
    } catch (e) {
      setState(() {
        _statusMessage = "Error reading card: ${e.toString()}";
        _isDetecting = false;
      });
    }
  }

  // Read card balance
  Future<void> _readCardBalance(String cardUID) async {
    setState(() {
      _statusMessage = "Reading card balance...";
    });

    try {
      final cardBalance = await _transactionService.getCardBalance(cardUID);
      setState(() {
        _cardBalance = cardBalance;
        _statusMessage = "Card balance: ${cardBalance.currency} ${cardBalance.balance.toStringAsFixed(2)}";
      });
      
      // Also fetch transaction history
      _fetchTransactionHistory(cardUID);
    } catch (e) {
      setState(() {
        _statusMessage = "Error reading balance: ${e.toString()}";
      });
    }
  }

  // Fetch transaction history
  Future<void> _fetchTransactionHistory(String cardUID) async {
    try {
      final transactions = await _transactionService.getCardTransactions(cardUID);
      setState(() {
        _transactions = transactions;
      });
    } catch (e) {
      print("Error fetching transactions: $e");
    }
  }

  // Process payment
  Future<void> _processPayment() async {
    if (_detectedCardUID == null) {
      setState(() {
        _statusMessage = "No card detected. Please tap a card first.";
      });
      return;
    }

    final double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() {
        _statusMessage = "Please enter a valid amount";
      });
      return;
    }

    if (_cardBalance != null && amount > _cardBalance!.balance) {
      setState(() {
        _statusMessage = "Insufficient balance";
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _statusMessage = "Processing payment...";
    });

    try {
      final transaction = await _transactionService.processCardPayment(
        CardPaymentRequest(
          cardId: _detectedCardUID!,
          amount: amount,
          merchantId: _merchantIdController.text,
          terminalId: _terminalIdController.text,
        ),
      );

      setState(() {
        _lastTransaction = transaction;
        _statusMessage = "Payment successful: ${_cardBalance?.currency ?? '₹'} ${amount.toStringAsFixed(2)}";
        _isProcessing = false;
      });

      // Read updated balance after successful payment
      _readCardBalance(_detectedCardUID!);
    } catch (e) {
      setState(() {
        _statusMessage = "Payment failed: ${e.toString()}";
        _isProcessing = false;
      });
    }
  }

  // Add funds to card
  Future<void> _addFunds() async {
    if (_detectedCardUID == null) {
      setState(() {
        _statusMessage = "No card detected. Please tap a card first.";
      });
      return;
    }

    final double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() {
        _statusMessage = "Please enter a valid amount";
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _statusMessage = "Adding funds...";
    });

    try {
      final transaction = await _transactionService.addFunds(
        cardUid: _detectedCardUID!,
        amount: amount,
        paymentMethod: 'cash', // Default to cash
      );

      setState(() {
        _lastTransaction = transaction;
        _statusMessage = "Funds added successfully: ${_cardBalance?.currency ?? '₹'} ${amount.toStringAsFixed(2)}";
        _isProcessing = false;
      });

      // Read updated balance after successful top-up
      _readCardBalance(_detectedCardUID!);
    } catch (e) {
      setState(() {
        _statusMessage = "Failed to add funds: ${e.toString()}";
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neptune Mock Testing'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // SDK Status card
            _buildStatusCard(),
            
            const SizedBox(height: 16),
            
            // Card detection card
            _buildCardDetectionCard(),
            
            const SizedBox(height: 16),
            
            // Payment details card
            _buildPaymentDetailsCard(),
            
            if (_lastTransaction != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: _buildLastTransactionCard(),
              ),
            
            if (_transactions != null && _transactions!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: _buildTransactionHistoryCard(),
              ),
              
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'SDK Status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isSDKInitialized ? Icons.check_circle : Icons.error,
                  color: _isSDKInitialized ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  _isSDKInitialized ? 'Reader Ready' : 'Reader Not Initialized',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSDKInitialized ? null : _initializeSDK,
              child: Text(_isSDKInitialized ? 'Initialized' : 'Initialize SDK'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardDetectionCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Card Detection',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (_detectedCardUID != null) ...[
              Row(
                children: [
                  Icon(Icons.credit_card, color: Colors.green),
                  const SizedBox(width: 8),
                  Text('Card UID: $_detectedCardUID'),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (_cardBalance != null) ...[
              Text(
                'Balance: ${_cardBalance!.currency} ${_cardBalance!.balance.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              Text(
                'Last Updated: ${_formatDateTime(_cardBalance!.lastUpdated)}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_isDetecting || !_isSDKInitialized) ? null : _startCardDetection,
                    icon: const Icon(Icons.sensors),
                    label: Text(_isDetecting ? 'Detecting...' : 'Detect Card'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_isDetecting || !_isSDKInitialized) ? null : _readCardManually,
                    icon: const Icon(Icons.contactless),
                    label: const Text('Read Card'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Transaction Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _merchantIdController,
              decoration: const InputDecoration(
                labelText: 'Merchant ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _terminalIdController,
              decoration: const InputDecoration(
                labelText: 'Terminal ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: '0.00',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_detectedCardUID == null || _isProcessing || !_isSDKInitialized)
                        ? null
                        : _processPayment,
                    icon: const Icon(Icons.payment),
                    label: Text(_isProcessing ? 'Processing...' : 'Process Payment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_detectedCardUID == null || _isProcessing || !_isSDKInitialized)
                        ? null
                        : _addFunds,
                    icon: const Icon(Icons.account_balance_wallet),
                    label: Text(_isProcessing ? 'Processing...' : 'Add Funds'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastTransactionCard() {
    return Card(
      elevation: 4,
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Last Transaction',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildTransactionDetail('Transaction ID', _lastTransaction!.transactionId),
            _buildTransactionDetail('Amount', '${_cardBalance?.currency ?? '₹'} ${_lastTransaction!.amount.toStringAsFixed(2)}'),
            _buildTransactionDetail('Status', _lastTransaction!.status),
            _buildTransactionDetail('Date', _formatDateTime(_lastTransaction!.timestamp)),
            _buildTransactionDetail('Merchant', _lastTransaction!.merchantId),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistoryCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Transaction History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _transactions!.length.clamp(0, 5), // Show max 5 transactions
              itemBuilder: (context, index) {
                final transaction = _transactions![index];
                return ListTile(
                  title: Text('${_cardBalance?.currency ?? '₹'} ${transaction.amount.toStringAsFixed(2)}'),
                  subtitle: Text('${transaction.status} - ${_formatDateTime(transaction.timestamp)}'),
                  trailing: transaction.amount > 0
                      ? Icon(Icons.add_circle, color: Colors.green)
                      : Icon(Icons.remove_circle, color: Colors.red),
                  dense: true,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
