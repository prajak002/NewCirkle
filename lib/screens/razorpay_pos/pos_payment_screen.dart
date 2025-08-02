import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/razorpay_pos/razorpay_pos_service.dart';
import '../../services/razorpay_pos/razorpay_pos_config.dart';

class POSPaymentScreen extends StatefulWidget {
  final PaymentTransaction? initialTransaction;

  const POSPaymentScreen({Key? key, this.initialTransaction}) : super(key: key);

  @override
  State<POSPaymentScreen> createState() => _POSPaymentScreenState();
}

class _POSPaymentScreenState extends State<POSPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _deviceIdController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _customerMobileController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _accountLabelController = TextEditingController();
  final _externalRefController = TextEditingController();
  
  String _selectedPaymentMode = RazorpayPOSConfig.paymentModeCard;
  String _selectedDeviceType = RazorpayPOSConfig.deviceTypeAndroid;
  bool _isLoading = false;
  PaymentTransaction? _currentTransaction;

  final List<String> _paymentModes = [
    RazorpayPOSConfig.paymentModeAll,
    RazorpayPOSConfig.paymentModeCard,
    RazorpayPOSConfig.paymentModeCash,
    RazorpayPOSConfig.paymentModeUPI,
    RazorpayPOSConfig.paymentModeBharatQR,
    RazorpayPOSConfig.paymentModeEMI,
  ];

  final List<String> _deviceTypes = [
    RazorpayPOSConfig.deviceTypeAndroid,
    RazorpayPOSConfig.deviceTypeSoundbox,
  ];

  @override
  void initState() {
    super.initState();
    _currentTransaction = widget.initialTransaction;
    if (_currentTransaction != null) {
      _populateFormFromTransaction(_currentTransaction!);
    }
  }

  void _populateFormFromTransaction(PaymentTransaction transaction) {
    _amountController.text = transaction.request.amount.toString();
    _deviceIdController.text = transaction.request.deviceId;
    _selectedPaymentMode = transaction.request.mode;
    _selectedDeviceType = transaction.request.deviceType;
    _customerNameController.text = transaction.request.customerName ?? '';
    _customerMobileController.text = transaction.request.customerMobileNumber ?? '';
    _customerEmailController.text = transaction.request.customerEmail ?? '';
    _accountLabelController.text = transaction.request.accountLabel ?? '';
    _externalRefController.text = transaction.request.externalRefNumber;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _deviceIdController.dispose();
    _customerNameController.dispose();
    _customerMobileController.dispose();
    _customerEmailController.dispose();
    _accountLabelController.dispose();
    _externalRefController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Bridge Payment'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          if (_currentTransaction != null)
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: _cancelCurrentTransaction,
              tooltip: 'Cancel Transaction',
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[800]!, Colors.blue[50]!],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildInfoCard(),
                      const SizedBox(height: 20),
                      if (_currentTransaction != null) ...[
                        _buildTransactionStatus(),
                        const SizedBox(height: 20),
                      ],
                      _buildPaymentForm(),
                    ],
                  ),
                ),
              ),
              if (_currentTransaction == null) _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.credit_card, color: Colors.blue[800]),
                const SizedBox(width: 8),
                const Text(
                  'POS Bridge Solution',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Features:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text('• Multi-mode payments (Card, UPI, Cash, etc.)'),
            const Text('• Server-to-server communication'),
            const Text('• Real-time transaction status'),
            const Text('• Multi-TID support with account labels'),
            const Text('• Automatic transaction monitoring'),
            const SizedBox(height: 8),
            Text(
              'Environment: ${RazorpayPOSConfig.isDemoMode ? 'DEMO' : 'PRODUCTION'}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: RazorpayPOSConfig.isDemoMode ? Colors.orange : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionStatus() {
    if (_currentTransaction == null) return const SizedBox.shrink();

    return StreamBuilder<PaymentTransaction>(
      stream: RazorpayPOSService().transactionStream,
      builder: (context, snapshot) {
        // Update current transaction if we receive an update
        if (snapshot.hasData && 
            snapshot.data!.id == _currentTransaction!.id) {
          _currentTransaction = snapshot.data!;
        }

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transaction Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildStatusIndicator(),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTransactionDetails(),
                if (_currentTransaction!.finalStatus != null) ...[
                  const SizedBox(height: 16),
                  _buildFinalStatusDetails(),
                ],
                if (_currentTransaction?.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _buildErrorDetails(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIndicator() {
    if (_currentTransaction == null) return const SizedBox.shrink();

    Color color;
    String text;
    IconData icon;

    switch (_currentTransaction!.result) {
      case PaymentResult.success:
        if (_currentTransaction!.finalStatus?.status == RazorpayPOSConfig.statusAuthorized) {
          color = Colors.green;
          text = 'SUCCESS';
          icon = Icons.check_circle;
        } else {
          color = Colors.blue;
          text = 'PROCESSING';
          icon = Icons.hourglass_empty;
        }
        break;
      case PaymentResult.failed:
        color = Colors.red;
        text = 'FAILED';
        icon = Icons.error;
        break;
      case PaymentResult.cancelled:
        color = Colors.orange;
        text = 'CANCELLED';
        icon = Icons.cancel;
        break;
      case PaymentResult.timeout:
        color = Colors.red;
        text = 'TIMEOUT';
        icon = Icons.timer_off;
        break;
      case PaymentResult.error:
        color = Colors.red;
        text = 'ERROR';
        icon = Icons.error_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetails() {
    if (_currentTransaction == null) return const SizedBox.shrink();

    return Column(
      children: [
        _buildDetailRow('Amount', '₹${_currentTransaction!.request.amount.toStringAsFixed(2)}'),
        _buildDetailRow('Reference', _currentTransaction!.request.externalRefNumber),
        _buildDetailRow('Payment Mode', _currentTransaction!.request.mode),
        _buildDetailRow('Device ID', _currentTransaction!.request.deviceId),
        if (_currentTransaction!.paymentResponse?.p2pRequestId != null)
          _buildDetailRow('P2P Request ID', _currentTransaction!.paymentResponse!.p2pRequestId!),
        _buildDetailRow('Created At', _formatDateTime(_currentTransaction!.createdAt)),
        if (_currentTransaction!.completedAt != null)
          _buildDetailRow('Completed At', _formatDateTime(_currentTransaction!.completedAt!)),
      ],
    );
  }

  Widget _buildFinalStatusDetails() {
    final status = _currentTransaction!.finalStatus!;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transaction Details',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (status.status != null)
            _buildDetailRow('Status', status.status!),
          if (status.txnId != null)
            _buildDetailRow('Transaction ID', status.txnId!),
          if (status.authCode != null)
            _buildDetailRow('Auth Code', status.authCode!),
          if (status.formattedPan != null)
            _buildDetailRow('Card Number', status.formattedPan!),
          if (status.paymentCardBrand != null)
            _buildDetailRow('Card Brand', status.paymentCardBrand!),
          if (status.receiptUrl != null)
            _buildDetailRow('Receipt URL', status.receiptUrl!, isUrl: true),
        ],
      ),
    );
  }

  Widget _buildErrorDetails() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _currentTransaction!.errorMessage!,
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isUrl = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: isUrl
                ? GestureDetector(
                    onTap: () {
                      // Here you can implement URL opening functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Receipt URL: $value')),
                      );
                    },
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentForm() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentTransaction != null ? 'Transaction Details' : 'Payment Details',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                enabled: _currentTransaction == null,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Amount (₹) *',
                  hintText: 'Enter amount',
                  prefixIcon: Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deviceIdController,
                enabled: _currentTransaction == null,
                decoration: const InputDecoration(
                  labelText: 'Device ID *',
                  hintText: 'Enter POS device ID',
                  prefixIcon: Icon(Icons.devices),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter device ID';
                  }
                  if (!RazorpayPOSService.isValidDeviceId(value)) {
                    return 'Invalid device ID format';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPaymentMode,
                decoration: const InputDecoration(
                  labelText: 'Payment Mode *',
                  border: OutlineInputBorder(),
                ),
                items: _paymentModes.map((mode) {
                  return DropdownMenuItem(
                    value: mode,
                    child: Text(mode),
                  );
                }).toList(),
                onChanged: _currentTransaction == null ? (value) {
                  setState(() {
                    _selectedPaymentMode = value!;
                  });
                } : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDeviceType,
                decoration: const InputDecoration(
                  labelText: 'Device Type *',
                  border: OutlineInputBorder(),
                ),
                items: _deviceTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.replaceAll('_', ' ').toUpperCase()),
                  );
                }).toList(),
                onChanged: _currentTransaction == null ? (value) {
                  setState(() {
                    _selectedDeviceType = value!;
                  });
                } : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _externalRefController,
                enabled: _currentTransaction == null,
                decoration: const InputDecoration(
                  labelText: 'External Reference Number',
                  hintText: 'Leave empty for auto-generation',
                  prefixIcon: Icon(Icons.receipt),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _customerNameController,
                enabled: _currentTransaction == null,
                decoration: const InputDecoration(
                  labelText: 'Customer Name',
                  hintText: 'Enter customer name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _customerMobileController,
                enabled: _currentTransaction == null,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: const InputDecoration(
                  labelText: 'Customer Mobile',
                  hintText: 'Enter 10-digit mobile number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _customerEmailController,
                enabled: _currentTransaction == null,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Customer Email',
                  hintText: 'Enter email address',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _accountLabelController,
                enabled: _currentTransaction == null,
                decoration: const InputDecoration(
                  labelText: 'Account Label (Multi-TID)',
                  hintText: 'For multi-TID scenarios',
                  prefixIcon: Icon(Icons.label),
                  border: OutlineInputBorder(),
                ),
              ),
              if (_currentTransaction == null && RazorpayPOSConfig.isDemoMode) ...[
                const SizedBox(height: 16),
                _buildTestAmountInfo(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestAmountInfo() {
    final amount = double.tryParse(_amountController.text);
    if (amount != null && RazorpayPOSService.isTestAmount(amount)) {
      final scenario = RazorpayPOSService.getTestScenario(amount);
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          border: Border.all(color: Colors.orange),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Test Scenario: $scenario',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _initiatePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Initiate Payment',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  void _initiatePayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text);
      final deviceId = _deviceIdController.text.trim();
      
      final transaction = await RazorpayPOSService().initiatePayment(
        amount: amount,
        deviceId: deviceId,
        deviceType: _selectedDeviceType,
        paymentMode: _selectedPaymentMode,
        externalRefNumber: _externalRefController.text.trim().isEmpty
            ? null
            : _externalRefController.text.trim(),
        customerName: _customerNameController.text.trim().isEmpty
            ? null
            : _customerNameController.text.trim(),
        customerMobile: _customerMobileController.text.trim().isEmpty
            ? null
            : _customerMobileController.text.trim(),
        customerEmail: _customerEmailController.text.trim().isEmpty
            ? null
            : _customerEmailController.text.trim(),
        accountLabel: _accountLabelController.text.trim().isEmpty
            ? null
            : _accountLabelController.text.trim(),
      );

      setState(() {
        _currentTransaction = transaction;
      });

      if (transaction.paymentResponse?.success == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment initiated successfully! Monitoring status...'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment initiation failed: ${transaction.errorMessage}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _cancelCurrentTransaction() async {
    if (_currentTransaction?.paymentResponse?.p2pRequestId == null) return;

    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cancel Transaction'),
          content: const Text('Are you sure you want to cancel this transaction?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes'),
            ),
          ],
        ),
      );

      if (result == true) {
        await RazorpayPOSService().cancelPayment(
          _currentTransaction!.id,
          _currentTransaction!.paymentResponse!.p2pRequestId!,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction cancelled successfully'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel transaction: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
