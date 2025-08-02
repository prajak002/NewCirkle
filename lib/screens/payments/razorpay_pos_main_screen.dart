import 'package:flutter/material.dart';
import '../models/razorpay_pos_service.dart';
import '../models/razorpay_pos_models.dart';
import '../models/razorpay_pos_settings.dart';
import '../models/razorpay_native_sdk.dart';

class RazorpayPOSMainScreen extends StatefulWidget {
  const RazorpayPOSMainScreen({Key? key}) : super(key: key);

  @override
  State<RazorpayPOSMainScreen> createState() => _RazorpayPOSMainScreenState();
}

class _RazorpayPOSMainScreenState extends State<RazorpayPOSMainScreen> {
  final _razorpayPOSService = RazorpayPOSService();
  final _settings = RazorpayPOSSettings();
  
  String _selectedPaymentMode = 'CARD';
  bool _useNativeSDK = true;
  bool _isSDKInitialized = false;
  bool _isLoading = false;
  String? _statusMessage;
  String? _lastTransactionId;

  final _amountController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _customerMobileController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _externalRefController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _initializeSDK();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _customerNameController.dispose();
    _customerMobileController.dispose();
    _customerEmailController.dispose();
    _externalRefController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    // Settings are loaded automatically by the service
  }

  Future<void> _initializeSDK() async {
    if (!_useNativeSDK) return;
    
    setState(() {
      _isLoading = true;
      _statusMessage = 'Initializing SDK...';
    });

    try {
      final appKey = await _settings.getAppKey();
      final username = await _settings.getUsername();
      
      if (appKey.isEmpty || username.isEmpty) {
        setState(() {
          _statusMessage = 'Please configure app key and username in settings';
          _isLoading = false;
        });
        return;
      }

      final result = await RazorpayNativeSDK.initializeSDK(
        appKey: appKey,
        username: username,
        mode: 'DEMO', // Change to 'PROD' for production
        prepareDevice: true,
      );

      setState(() {
        _isSDKInitialized = result['success'] == true;
        _statusMessage = result['message'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error initializing SDK: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _makePayment() async {
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

    setState(() {
      _isLoading = true;
      _statusMessage = 'Processing payment...';
    });

    try {
      Map<String, dynamic> result;

      if (_useNativeSDK && _isSDKInitialized) {
        // Use native SDK
        switch (_selectedPaymentMode) {
          case 'CARD':
            result = await RazorpayNativeSDK.cardPayment(
              amount: amount,
              externalRefNumber: _externalRefController.text,
              customerName: _customerNameController.text,
              customerMobile: _customerMobileController.text,
              customerEmail: _customerEmailController.text,
            );
            break;
          case 'UPI':
            result = await RazorpayNativeSDK.upiPayment(
              amount: amount,
              externalRefNumber: _externalRefController.text,
              customerName: _customerNameController.text,
              customerMobile: _customerMobileController.text,
              customerEmail: _customerEmailController.text,
            );
            break;
          case 'CASH':
            result = await RazorpayNativeSDK.cashPayment(
              amount: amount,
              externalRefNumber: _externalRefController.text,
              customerName: _customerNameController.text,
              customerMobile: _customerMobileController.text,
              customerEmail: _customerEmailController.text,
            );
            break;
          default:
            result = await RazorpayNativeSDK.makePayment(
              amount: amount,
              externalRefNumber: _externalRefController.text,
              customerName: _customerNameController.text,
              customerMobile: _customerMobileController.text,
              customerEmail: _customerEmailController.text,
            );
        }
      } else {
        // Use HTTP API
        final paymentRequest = PaymentRequest(
          mode: _selectedPaymentMode,
          amount: amount,
          externalRefNumber: _externalRefController.text.isNotEmpty 
              ? _externalRefController.text 
              : 'REF_${DateTime.now().millisecondsSinceEpoch}',
          customerReceiptFlag: true,
          merchantReceiptFlag: true,
        );

        final response = await _razorpayPOSService.makePayment(paymentRequest);
        result = {
          'success': response.status == 'success',
          'txnId': response.txnId,
          'message': response.message,
          'status': response.status,
        };
      }

      setState(() {
        _lastTransactionId = result['txnId'];
        _statusMessage = result['message'];
        _isLoading = false;
      });

      if (result['success'] == true) {
        _showSuccessDialog(result);
      } else {
        _showErrorDialog(result['message'] ?? 'Payment failed');
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
        _isLoading = false;
      });
      _showErrorDialog('Payment failed: $e');
    }
  }

  Future<void> _voidPayment() async {
    if (_lastTransactionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transaction to void')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Voiding payment...';
    });

    try {
      Map<String, dynamic> result;

      if (_useNativeSDK && _isSDKInitialized) {
        result = await RazorpayNativeSDK.voidPayment(txnId: _lastTransactionId!);
      } else {
        // Use HTTP API for cancellation
        final cancelRequest = CancelRequest(
          txnId: _lastTransactionId!,
        );
        final response = await _razorpayPOSService.cancelPayment(cancelRequest);
        result = {
          'success': response.status == 'success',
          'message': response.message,
        };
      }

      setState(() {
        _statusMessage = result['message'];
        _isLoading = false;
      });

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error voiding payment: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _printReceipt() async {
    if (_lastTransactionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transaction to print')),
      );
      return;
    }

    if (_useNativeSDK && _isSDKInitialized) {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Printing receipt...';
      });

      try {
        final result = await RazorpayNativeSDK.printReceipt(txnId: _lastTransactionId!);
        setState(() {
          _statusMessage = result['message'];
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _statusMessage = 'Error printing receipt: $e';
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt printing only available with native SDK')),
      );
    }
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transaction ID: ${result['txnId']}'),
            Text('Amount: ₹${_amountController.text}'),
            Text('Payment Mode: $_selectedPaymentMode'),
            Text('Status: ${result['status'] ?? 'SUCCESS'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          if (_useNativeSDK && _isSDKInitialized)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _printReceipt();
              },
              child: const Text('Print Receipt'),
            ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Failed'),
        content: Text(message),
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
        title: const Text('Razorpay POS'),
        actions: [
          IconButton(
            icon: Icon(_useNativeSDK ? Icons.phone_android : Icons.cloud),
            onPressed: () {
              setState(() {
                _useNativeSDK = !_useNativeSDK;
                _isSDKInitialized = false;
              });
              if (_useNativeSDK) {
                _initializeSDK();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/razorpay_pos_setup');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // SDK Status Card
            Card(
              color: _useNativeSDK
                  ? (_isSDKInitialized ? Colors.green[50] : Colors.orange[50])
                  : Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _useNativeSDK ? Icons.phone_android : Icons.cloud,
                          color: _useNativeSDK
                              ? (_isSDKInitialized ? Colors.green : Colors.orange)
                              : Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _useNativeSDK ? 'Native SDK Mode' : 'HTTP API Mode',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage ?? 'Ready',
                      style: TextStyle(
                        color: _useNativeSDK
                            ? (_isSDKInitialized ? Colors.green : Colors.orange)
                            : Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Payment Mode Selection
            const Text('Payment Mode:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: ['CARD', 'UPI', 'CASH', 'ALL'].map((mode) {
                return ChoiceChip(
                  label: Text(mode),
                  selected: _selectedPaymentMode == mode,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedPaymentMode = mode;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

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
                      controller: _externalRefController,
                      decoration: const InputDecoration(
                        labelText: 'Reference Number (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _customerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Customer Name (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _customerMobileController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Customer Mobile (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _customerEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Customer Email (Optional)',
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
              onPressed: _isLoading ? null : _makePayment,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
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
                  : Text('Make Payment ($_selectedPaymentMode)'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _lastTransactionId != null && !_isLoading
                        ? _voidPayment
                        : null,
                    child: const Text('Void Last Payment'),
                  ),
                ),
                const SizedBox(width: 10),
                if (_useNativeSDK && _isSDKInitialized)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _lastTransactionId != null && !_isLoading
                          ? _printReceipt
                          : null,
                      child: const Text('Print Receipt'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
