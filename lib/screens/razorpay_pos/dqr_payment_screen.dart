import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/razorpay_pos/razorpay_pos_service.dart';
import '../../services/razorpay_pos/razorpay_pos_config.dart';

class DQRPaymentScreen extends StatefulWidget {
  const DQRPaymentScreen({Key? key}) : super(key: key);

  @override
  State<DQRPaymentScreen> createState() => _DQRPaymentScreenState();
}

class _DQRPaymentScreenState extends State<DQRPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _deviceIdController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _customerMobileController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _externalRefController = TextEditingController();
  
  bool _isLoading = false;
  PaymentTransaction? _currentTransaction;
  String? _generatedQRData;

  @override
  void dispose() {
    _amountController.dispose();
    _deviceIdController.dispose();
    _customerNameController.dispose();
    _customerMobileController.dispose();
    _customerEmailController.dispose();
    _externalRefController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DQR Payment Solution'),
        backgroundColor: Colors.green[800],
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
            colors: [Colors.green[800]!, Colors.green[50]!],
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
                      if (_generatedQRData != null) ...[
                        _buildQRCodeDisplay(),
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
                Icon(Icons.qr_code, color: Colors.green[800]),
                const SizedBox(width: 8),
                const Text(
                  'Dynamic QR Solution',
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
            const Text('• Customer-facing Dynamic QR generation'),
            const Text('• UPI-based payments'),
            const Text('• Integrated billing system'),
            const Text('• Real-time payment confirmation'),
            const Text('• Transparent reconciliation'),
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

  Widget _buildQRCodeDisplay() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Dynamic QR Code',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: QrImageView(
                data: _generatedQRData!,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ask customer to scan this QR code with any UPI app',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: _shareQRCode,
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                ),
                TextButton.icon(
                  onPressed: _copyQRData,
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy'),
                ),
              ],
            ),
          ],
        ),
      ),
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
          text = 'WAITING FOR PAYMENT';
          icon = Icons.qr_code_scanner;
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
        _buildDetailRow('Payment Mode', 'UPI (Dynamic QR)'),
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
            'Payment Details',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (status.status != null)
            _buildDetailRow('Status', status.status!),
          if (status.txnId != null)
            _buildDetailRow('Transaction ID', status.txnId!),
          if (status.payerName != null)
            _buildDetailRow('Payer Name', status.payerName!),
          if (status.customerMobile != null)
            _buildDetailRow('Customer Mobile', status.customerMobile!),
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
                _currentTransaction != null ? 'Payment Details' : 'DQR Payment Setup',
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
                  hintText: 'Enter amount for QR generation',
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
                  hintText: 'Enter Soundbox device ID',
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
              TextFormField(
                controller: _externalRefController,
                enabled: _currentTransaction == null,
                decoration: const InputDecoration(
                  labelText: 'Reference Number',
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
              if (_currentTransaction == null && RazorpayPOSConfig.isDemoMode) ...[
                const SizedBox(height: 16),
                _buildDemoNote(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text(
                'Demo Mode Active',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'In demo mode, the QR code will be generated but actual payment processing may vary. Use this for testing the integration flow.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
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
              onPressed: _isLoading ? null : _generateDQR,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
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
                      'Generate DQR',
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

  void _generateDQR() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text);
      final deviceId = _deviceIdController.text.trim();
      
      // Generate QR data (simplified version - in production, this would be more complex)
      final qrData = _generateQRData(amount, deviceId);
      
      final transaction = await RazorpayPOSService().initiateDQRPayment(
        amount: amount,
        deviceId: deviceId,
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
      );

      setState(() {
        _currentTransaction = transaction;
        _generatedQRData = qrData;
      });

      if (transaction.paymentResponse?.success == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('DQR generated successfully! Waiting for payment...'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'DQR generation failed: ${transaction.errorMessage}',
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

  String _generateQRData(double amount, String deviceId) {
    // Simplified UPI QR generation - in production, this would be more sophisticated
    // and might involve calling additional APIs to get proper UPI payment links
    final refNumber = _externalRefController.text.trim().isEmpty
        ? 'DQR_${DateTime.now().millisecondsSinceEpoch}'
        : _externalRefController.text.trim();
    
    final customerName = _customerNameController.text.trim().isEmpty
        ? 'Customer'
        : _customerNameController.text.trim();
    
    // This is a simplified UPI payment string format
    // In production, you would get this from Razorpay's API response
    return 'upi://pay?pa=merchant@razorpay&pn=Razorpay%20Merchant&am=${amount.toStringAsFixed(2)}&cu=INR&tn=Payment%20for%20$refNumber&tr=$refNumber';
  }

  void _shareQRCode() {
    if (_generatedQRData != null) {
      // In production, you would implement actual sharing functionality
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR sharing functionality would be implemented here'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _copyQRData() {
    if (_generatedQRData != null) {
      Clipboard.setData(ClipboardData(text: _generatedQRData!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR data copied to clipboard'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _cancelCurrentTransaction() async {
    if (_currentTransaction?.paymentResponse?.p2pRequestId == null) return;

    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cancel Transaction'),
          content: const Text('Are you sure you want to cancel this DQR payment?'),
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

        setState(() {
          _generatedQRData = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('DQR transaction cancelled successfully'),
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
