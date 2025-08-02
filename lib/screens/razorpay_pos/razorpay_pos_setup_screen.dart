import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/razorpay_pos/razorpay_pos_config.dart';
import '../../services/razorpay_pos/razorpay_pos_settings.dart';
import '../../services/razorpay_pos/razorpay_pos_service.dart';

class RazorpayPOSSetupScreen extends StatefulWidget {
  const RazorpayPOSSetupScreen({Key? key}) : super(key: key);

  @override
  State<RazorpayPOSSetupScreen> createState() => _RazorpayPOSSetupScreenState();
}

class _RazorpayPOSSetupScreenState extends State<RazorpayPOSSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _appKeyController = TextEditingController();
  final _usernameController = TextEditingController();
  final _deviceIdController = TextEditingController();
  final _accountLabelController = TextEditingController();
  final _merchantNameController = TextEditingController();
  
  String _selectedDeviceType = RazorpayPOSConfig.deviceTypeAndroid;
  bool _isLoading = false;
  bool _isConfigured = false;

  final List<String> _deviceTypes = [
    RazorpayPOSConfig.deviceTypeAndroid,
    RazorpayPOSConfig.deviceTypeSoundbox,
  ];

  @override
  void initState() {
    super.initState();
    _loadConfiguration();
  }

  void _loadConfiguration() async {
    final config = await RazorpayPOSSettings.getConfiguration();
    setState(() {
      _appKeyController.text = config['appKey'] ?? '';
      _usernameController.text = config['username'] ?? '';
      _deviceIdController.text = config['deviceId'] ?? '';
      _selectedDeviceType = config['deviceType'] ?? RazorpayPOSConfig.deviceTypeAndroid;
      _accountLabelController.text = config['accountLabel'] ?? '';
      _merchantNameController.text = config['merchantName'] ?? '';
      _isConfigured = config['isConfigured'] ?? false;
    });
  }

  @override
  void dispose() {
    _appKeyController.dispose();
    _usernameController.dispose();
    _deviceIdController.dispose();
    _accountLabelController.dispose();
    _merchantNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Razorpay POS Setup'),
        backgroundColor: Colors.purple[800],
        foregroundColor: Colors.white,
        actions: [
          if (_isConfigured)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _clearConfiguration,
              tooltip: 'Clear Configuration',
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple[800]!, Colors.purple[50]!],
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
                      _buildHeaderCard(),
                      const SizedBox(height: 20),
                      _buildConfigurationForm(),
                      const SizedBox(height: 20),
                      _buildInstructionsCard(),
                    ],
                  ),
                ),
              ),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Colors.purple[800]),
                const SizedBox(width: 8),
                const Text(
                  'POS Configuration',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _isConfigured ? Icons.check_circle : Icons.warning,
                  color: _isConfigured ? Colors.green : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _isConfigured ? 'Configuration Complete' : 'Configuration Required',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _isConfigured ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
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

  Widget _buildConfigurationForm() {
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
                'Merchant Configuration',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _appKeyController,
                decoration: const InputDecoration(
                  labelText: 'App Key *',
                  hintText: 'Enter your Razorpay POS App Key',
                  prefixIcon: Icon(Icons.key),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter App Key';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username *',
                  hintText: 'Enter merchant username',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _merchantNameController,
                decoration: const InputDecoration(
                  labelText: 'Merchant Name',
                  hintText: 'Enter your business name',
                  prefixIcon: Icon(Icons.business),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Device Configuration',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deviceIdController,
                decoration: const InputDecoration(
                  labelText: 'Device ID *',
                  hintText: 'Enter POS device serial number',
                  prefixIcon: Icon(Icons.devices),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter device ID';
                  }
                  if (!RazorpayPOSService.isValidDeviceId(value)) {
                    return 'Invalid device ID format (min 8 alphanumeric chars)';
                  }
                  return null;
                },
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
                    child: Text(_getDeviceTypeDisplayName(type)),
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
                controller: _accountLabelController,
                decoration: const InputDecoration(
                  labelText: 'Account Label (Optional)',
                  hintText: 'For multi-TID scenarios',
                  prefixIcon: Icon(Icons.label),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Setup Instructions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInstructionStep(
              '1.',
              'Get your App Key from Razorpay POS solution consultant',
            ),
            _buildInstructionStep(
              '2.',
              'Enter your merchant username provided by Razorpay',
            ),
            _buildInstructionStep(
              '3.',
              'Configure your POS device ID (serial number)',
            ),
            _buildInstructionStep(
              '4.',
              'Select appropriate device type (Android POS/Soundbox)',
            ),
            _buildInstructionStep(
              '5.',
              'Add account label if using multi-TID setup',
            ),
            _buildInstructionStep(
              '6.',
              'Test the configuration with a small amount',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border.all(color: Colors.blue[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Contact Razorpay support if you need help with configuration or face any issues.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String instruction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.purple[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[800],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              instruction,
              style: const TextStyle(fontSize: 14),
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
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _testConfiguration,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[700],
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
                  : const Text('Test Config'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveConfiguration,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[800],
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
                      'Save Configuration',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDeviceTypeDisplayName(String deviceType) {
    switch (deviceType) {
      case RazorpayPOSConfig.deviceTypeAndroid:
        return 'Android POS';
      case RazorpayPOSConfig.deviceTypeSoundbox:
        return 'Soundbox';
      default:
        return deviceType;
    }
  }

  void _saveConfiguration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await RazorpayPOSSettings.saveConfiguration(
        appKey: _appKeyController.text.trim(),
        username: _usernameController.text.trim(),
        deviceId: _deviceIdController.text.trim(),
        deviceType: _selectedDeviceType,
        accountLabel: _accountLabelController.text.trim().isEmpty
            ? null
            : _accountLabelController.text.trim(),
        merchantName: _merchantNameController.text.trim().isEmpty
            ? null
            : _merchantNameController.text.trim(),
      );

      setState(() {
        _isConfigured = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configuration saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving configuration: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _testConfiguration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create a test transaction with amount 1.00
      final transaction = await RazorpayPOSService().createTestPayment(
        amount: 1.00,
        deviceId: _deviceIdController.text.trim(),
        deviceType: _selectedDeviceType,
        paymentMode: RazorpayPOSConfig.paymentModeCard,
      );

      if (transaction.paymentResponse?.success == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test configuration successful! Device is reachable.'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Cancel the test transaction
        if (transaction.paymentResponse?.p2pRequestId != null) {
          await RazorpayPOSService().cancelPayment(
            transaction.id,
            transaction.paymentResponse!.p2pRequestId!,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Test failed: ${transaction.errorMessage ?? 'Unknown error'}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Test error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearConfiguration() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Configuration'),
        content: const Text(
          'Are you sure you want to clear all POS configuration? '
          'You will need to set it up again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (result == true) {
      await RazorpayPOSSettings.clearConfiguration();
      _loadConfiguration();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configuration cleared successfully!'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}
