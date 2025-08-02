import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/razorpay_pos/razorpay_pos_service.dart';
import '../../services/razorpay_pos/razorpay_pos_config.dart';
import '../../services/razorpay_pos/razorpay_pos_settings.dart';
import 'pos_payment_screen.dart';
import 'dqr_payment_screen.dart';
import 'razorpay_pos_setup_screen.dart';

class RazorpayPOSScreen extends StatefulWidget {
  const RazorpayPOSScreen({Key? key}) : super(key: key);

  @override
  State<RazorpayPOSScreen> createState() => _RazorpayPOSScreenState();
}

class _RazorpayPOSScreenState extends State<RazorpayPOSScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _deviceIdController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _customerMobileController = TextEditingController();
  final _customerEmailController = TextEditingController();
  
  String _selectedPaymentMode = RazorpayPOSConfig.paymentModeCard;
  String _selectedDeviceType = RazorpayPOSConfig.deviceTypeAndroid;
  bool _isLoading = false;
  bool _isConfigured = false;

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
    _checkConfiguration();
  }

  void _checkConfiguration() async {
    final isConfigured = await RazorpayPOSSettings.isConfigured();
    final config = await RazorpayPOSSettings.getConfiguration();
    
    setState(() {
      _isConfigured = isConfigured;
      if (isConfigured) {
        _deviceIdController.text = config['deviceId'] ?? '';
        _selectedDeviceType = config['deviceType'] ?? RazorpayPOSConfig.deviceTypeAndroid;
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _deviceIdController.dispose();
    _customerNameController.dispose();
    _customerMobileController.dispose();
    _customerEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Razorpay POS Integration'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSetup,
            tooltip: 'POS Setup',
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildEnvironmentCard(),
                const SizedBox(height: 20),
                if (!_isConfigured) ...[
                  _buildSetupRequiredCard(),
                  const SizedBox(height: 20),
                ],
                _buildSolutionButtons(),
                const SizedBox(height: 20),
                _buildPaymentForm(),
                const SizedBox(height: 20),
                _buildActiveTransactions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSetupRequiredCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Setup Required',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Razorpay POS is not configured yet. Please complete the setup to start processing payments.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _navigateToSetup,
                icon: const Icon(Icons.settings),
                label: const Text('Configure Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSetup() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RazorpayPOSSetupScreen(),
      ),
    );
    
    if (result == true) {
      _checkConfiguration();
    }
  }
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  RazorpayPOSConfig.isDemoMode ? Icons.bug_report : Icons.verified,
                  color: RazorpayPOSConfig.isDemoMode ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  'Environment: ${RazorpayPOSConfig.isDemoMode ? 'DEMO' : 'PRODUCTION'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (RazorpayPOSConfig.isDemoMode) ...[
              const Text(
                '⚠️ Demo Mode Active',
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              const Text(
                'Use test amounts to simulate different scenarios. Check the documentation for test amount mapping.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ] else ...[
              const Text(
                '✅ Production Mode',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              const Text(
                'Live transactions will be processed.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSolutionButtons() {
    return Column(
      children: [
        const Text(
          'Choose Integration Solution',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSolutionButton(
                title: 'POS Bridge',
                subtitle: 'Card & Multi-mode Payments',
                icon: Icons.credit_card,
                color: Colors.blue,
                onTap: () => _navigateToPOSPayment(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSolutionButton(
                title: 'DQR Solution',
                subtitle: 'Dynamic QR Payments',
                icon: Icons.qr_code,
                color: Colors.green,
                onTap: () => _navigateToDQRPayment(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSolutionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
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
              const Text(
                'Quick Payment Test',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Amount (₹)',
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
                decoration: const InputDecoration(
                  labelText: 'Device ID',
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
                  labelText: 'Payment Mode',
                  border: OutlineInputBorder(),
                ),
                items: _paymentModes.map((mode) {
                  return DropdownMenuItem(
                    value: mode,
                    child: Text(mode),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMode = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDeviceType,
                decoration: const InputDecoration(
                  labelText: 'Device Type',
                  border: OutlineInputBorder(),
                ),
                items: _deviceTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.replaceAll('_', ' ').toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDeviceType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _customerNameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name (Optional)',
                  hintText: 'Enter customer name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _customerMobileController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: const InputDecoration(
                  labelText: 'Customer Mobile (Optional)',
                  hintText: 'Enter 10-digit mobile number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _customerEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Customer Email (Optional)',
                  hintText: 'Enter email address',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _initiateQuickPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Initiate Payment',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
              if (RazorpayPOSConfig.isDemoMode) ...[
                const SizedBox(height: 12),
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

  Widget _buildActiveTransactions() {
    return StreamBuilder<PaymentTransaction>(
      stream: RazorpayPOSService().transactionStream,
      builder: (context, snapshot) {
        final activeTransactions = RazorpayPOSService().getActiveTransactions();
        
        if (activeTransactions.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Active Transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...activeTransactions.map((transaction) =>
                    _buildTransactionCard(transaction)).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionCard(PaymentTransaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${transaction.request.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(transaction.result),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Ref: ${transaction.request.externalRefNumber}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              'Mode: ${transaction.request.mode}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (transaction.paymentResponse?.p2pRequestId != null)
              Text(
                'ID: ${transaction.paymentResponse!.p2pRequestId}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(PaymentResult result) {
    Color color;
    String text;
    
    switch (result) {
      case PaymentResult.success:
        color = Colors.green;
        text = 'Processing';
        break;
      case PaymentResult.failed:
        color = Colors.red;
        text = 'Failed';
        break;
      case PaymentResult.cancelled:
        color = Colors.orange;
        text = 'Cancelled';
        break;
      case PaymentResult.timeout:
        color = Colors.red;
        text = 'Timeout';
        break;
      case PaymentResult.error:
        color = Colors.red;
        text = 'Error';
        break;
    }

    return Chip(
      label: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
    );
  }

  void _navigateToPOSPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const POSPaymentScreen(),
      ),
    );
  }

  void _navigateToDQRPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DQRPaymentScreen(),
      ),
    );
  }

  void _initiateQuickPayment() async {
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
        customerName: _customerNameController.text.trim().isEmpty
            ? null
            : _customerNameController.text.trim(),
        customerMobile: _customerMobileController.text.trim().isEmpty
            ? null
            : _customerMobileController.text.trim(),
        customerEmail: _customerEmailController.text.trim().isEmpty
            ? null
            : _customerEmailController.text.trim(),
      );

      if (transaction.paymentResponse?.success == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment initiated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to payment screen for monitoring
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => POSPaymentScreen(
              initialTransaction: transaction,
            ),
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
}
