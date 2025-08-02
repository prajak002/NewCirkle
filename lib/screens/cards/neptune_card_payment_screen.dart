import 'package:flutter/material.dart';
import 'dart:async';
import '../services/neptune/neptune_service.dart';
import '../services/card_transaction_service.dart';
import '../models/card_models.dart';

class NeptuneCardPaymentScreen extends StatefulWidget {
  const NeptuneCardPaymentScreen({Key? key}) : super(key: key);

  @override
  State<NeptuneCardPaymentScreen> createState() => _NeptuneCardPaymentScreenState();
}

class _NeptuneCardPaymentScreenState extends State<NeptuneCardPaymentScreen> {
  final _amountController = TextEditingController();
  final _merchantIdController = TextEditingController();
  final _terminalIdController = TextEditingController();
  
  bool _isSDKInitialized = false;
  bool _isDetecting = false;
  bool _isProcessing = false;
  String? _statusMessage;
  String? _detectedCardUID;
  CardBalance? _cardBalance;
  CardTransaction? _lastTransaction;
  
  StreamSubscription? _cardDetectionSubscription;

  @override
  void initState() {
    super.initState();
    _initializeSDK();
    _setupCardDetectionListener();
  }

  @override
  void dispose() {
    _stopCardDetection();
    _cardDetectionSubscription?.cancel();
    _amountController.dispose();
    _merchantIdController.dispose();
    _terminalIdController.dispose();
    super.dispose();
  }

  Future<void> _initializeSDK() async {
    setState(() {
      _statusMessage = 'Initializing Neptune SDK...';
    });

    try {
      final success = await NeptuneService.initializeSDK();
      setState(() {
        _isSDKInitialized = success;
        _statusMessage = success 
            ? 'Neptune SDK initialized successfully' 
            : 'Failed to initialize Neptune SDK';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error initializing SDK: $e';
      });
    }
  }

  void _setupCardDetectionListener() {
    NeptuneService.setCardDetectionListener(
      (String uid) {
        setState(() {
          _detectedCardUID = uid;
          _statusMessage = 'Card detected: $uid';
        });
        _getCardBalance(uid);
      },
      (String error) {
        setState(() {
          _statusMessage = 'Card detection error: $error';
        });
      },
    );
  }

  Future<void> _startCardDetection() async {
    if (!_isSDKInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please initialize SDK first')),
      );
      return;
    }

    setState(() {
      _statusMessage = 'Starting card detection...';
    });

    try {
      final success = await NeptuneService.startCardDetection();
      setState(() {
        _isDetecting = success;
        _statusMessage = success 
            ? 'Card detection started. Please tap a card...' 
            : 'Failed to start card detection';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error starting card detection: $e';
      });
    }
  }

  Future<void> _stopCardDetection() async {
    try {
      final success = await NeptuneService.stopCardDetection();
      setState(() {
        _isDetecting = false;
        _statusMessage = success 
            ? 'Card detection stopped' 
            : 'Failed to stop card detection';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error stopping card detection: $e';
      });
    }
  }

  Future<void> _readSingleCard() async {
    if (!_isSDKInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please initialize SDK first')),
      );
      return;
    }

    setState(() {
      _statusMessage = 'Reading card... Please tap a card';
    });

    try {
      final uid = await NeptuneService.readCardUID();
      if (uid != null) {
        setState(() {
          _detectedCardUID = uid;
          _statusMessage = 'Card read: $uid';
        });
        await _getCardBalance(uid);
      } else {
        setState(() {
          _statusMessage = 'No card detected or read failed';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error reading card: $e';
      });
    }
  }

  Future<void> _getCardBalance(String cardUID) async {
    try {
      final balance = await CardTransactionService.getCardBalance(cardUID);
      setState(() {
        _cardBalance = balance;
      });
    } catch (e) {
      print('Error getting card balance: $e');
    }
  }

  Future<void> _processPayment() async {
    if (_detectedCardUID == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please detect a card first')),
      );
      return;
    }

    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter amount')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid amount')),
      );
      return;
    }

    // Check if card has sufficient balance
    if (_cardBalance != null && _cardBalance!.balance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient balance. Available: ₹${_cardBalance!.balance.toStringAsFixed(2)}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Processing payment...';
    });

    try {
      final transaction = await CardTransactionService.processPayment(
        cardUid: _detectedCardUID!,
        amount: amount,
        merchantId: _merchantIdController.text.isNotEmpty 
            ? _merchantIdController.text 
            : null,
        terminalId: _terminalIdController.text.isNotEmpty 
            ? _terminalIdController.text 
            : null,
        metadata: {
          'paymentMethod': 'card_tap',
          'deviceType': 'neptune_pos',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (transaction != null) {
        setState(() {
          _lastTransaction = transaction;
          _statusMessage = 'Payment successful! Transaction ID: ${transaction.transactionId}';
        });
        
        // Refresh card balance
        await _getCardBalance(_detectedCardUID!);
        
        _showPaymentSuccessDialog(transaction);
      } else {
        setState(() {
          _statusMessage = 'Payment failed. Please try again.';
        });
        _showPaymentFailedDialog();
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Payment error: $e';
      });
      _showPaymentFailedDialog();
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _addFunds() async {
    if (_detectedCardUID == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please detect a card first')),
      );
      return;
    }

    final result = await showDialog<double>(
      context: context,
      builder: (context) => _AddFundsDialog(),
    );

    if (result != null && result > 0) {
      setState(() {
        _isProcessing = true;
        _statusMessage = 'Adding funds...';
      });

      try {
        final success = await CardTransactionService.addFunds(
          cardUid: _detectedCardUID!,
          amount: result,
          paymentMethod: 'cash', // or get from user
          metadata: {
            'addedBy': 'pos_terminal',
            'timestamp': DateTime.now().toIso8601String(),
          },
        );

        if (success) {
          setState(() {
            _statusMessage = 'Funds added successfully!';
          });
          
          // Refresh card balance
          await _getCardBalance(_detectedCardUID!);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('₹${result.toStringAsFixed(2)} added to card'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() {
            _statusMessage = 'Failed to add funds';
          });
        }
      } catch (e) {
        setState(() {
          _statusMessage = 'Error adding funds: $e';
        });
      } finally {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showPaymentSuccessDialog(CardTransaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transaction ID: ${transaction.transactionId}'),
            Text('Card UID: ${transaction.cardUid}'),
            Text('Amount: ₹${transaction.amount.toStringAsFixed(2)}'),
            Text('Status: ${transaction.status}'),
            if (_cardBalance != null)
              Text('Remaining Balance: ₹${_cardBalance!.balance.toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPaymentFailedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Failed'),
        content: Text(_statusMessage ?? 'Payment processing failed'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neptune Card Payment'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // SDK Status Card
            Card(
              color: _isSDKInitialized ? Colors.green[50] : Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isSDKInitialized ? Icons.check_circle : Icons.error,
                          color: _isSDKInitialized ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isSDKInitialized ? 'Neptune SDK Ready' : 'SDK Not Initialized',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage ?? 'Ready',
                      style: TextStyle(
                        color: _isSDKInitialized ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Card Detection Controls
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isDetecting ? _stopCardDetection : _startCardDetection,
                    icon: Icon(_isDetecting ? Icons.stop : Icons.play_arrow),
                    label: Text(_isDetecting ? 'Stop Detection' : 'Start Detection'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isDetecting ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _readSingleCard,
                    icon: const Icon(Icons.credit_card),
                    label: const Text('Read Single Card'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Detected Card Info
            if (_detectedCardUID != null) ...[
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detected Card',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text('UID: $_detectedCardUID'),
                      if (_cardBalance != null) ...[
                        Text('Balance: ₹${_cardBalance!.balance.toStringAsFixed(2)}'),
                        Text('Currency: ${_cardBalance!.currency}'),
                        Text('Last Updated: ${_cardBalance!.lastUpdated.toString().split('.')[0]}'),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Payment Form
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Amount (₹)',
                        border: OutlineInputBorder(),
                        prefixText: '₹ ',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _merchantIdController,
                      decoration: const InputDecoration(
                        labelText: 'Merchant ID (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _terminalIdController,
                      decoration: const InputDecoration(
                        labelText: 'Terminal ID (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action Buttons
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isProcessing ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: _isProcessing
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                        SizedBox(width: 10),
                        Text('Processing...'),
                      ],
                    )
                  : const Text('Process Payment'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: _isProcessing ? null : _addFunds,
              child: const Text('Add Funds to Card'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddFundsDialog extends StatefulWidget {
  @override
  State<_AddFundsDialog> createState() => _AddFundsDialogState();
}

class _AddFundsDialogState extends State<_AddFundsDialog> {
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Funds'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Enter amount to add to the card:'),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount (₹)',
              border: OutlineInputBorder(),
              prefixText: '₹ ',
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Note: This will be processed as a cash transaction',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final amount = double.tryParse(_amountController.text);
            Navigator.pop(context, amount);
          },
          child: const Text('Add Funds'),
        ),
      ],
    );
  }
}
