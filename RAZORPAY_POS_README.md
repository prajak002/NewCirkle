# Razorpay POS Integration for Flutter

This implementation provides a comprehensive integration of Razorpay POS solutions for your Flutter application, supporting both POS Bridge and Dynamic QR (DQR) payment methods.

## Features

### 🏪 POS Bridge Solution
- **Multi-mode payments**: Card, UPI, Cash, BharatQR, EMI
- **Server-to-server communication** with POS terminals
- **Real-time transaction monitoring** with automatic status checking
- **Multi-TID support** using account labels
- **Device connectivity management**

### 📱 Dynamic QR (DQR) Solution
- **Customer-facing QR generation** for UPI payments
- **Integrated billing system** support
- **Real-time payment confirmation**
- **QR code sharing and management**

### ⚙️ Configuration Management
- **Persistent settings storage** using SharedPreferences
- **Environment switching** (Demo/Production)
- **Device configuration** and validation
- **Setup wizard** for easy onboarding

## Implementation Overview

### File Structure
```
lib/
├── services/razorpay_pos/
│   ├── razorpay_pos_config.dart      # Configuration constants
│   ├── razorpay_pos_models.dart      # Data models
│   ├── razorpay_pos_service.dart     # Core service implementation
│   └── razorpay_pos_settings.dart    # Settings management
└── screens/razorpay_pos/
    ├── razorpay_pos_screen.dart      # Main integration screen
    ├── pos_payment_screen.dart       # POS Bridge payment interface
    ├── dqr_payment_screen.dart       # DQR payment interface
    └── razorpay_pos_setup_screen.dart # Configuration setup
```

## Getting Started

### 1. Prerequisites
- **Demo/Production account** with Razorpay POS
- **App Key** provided by Razorpay solution consultant
- **POS device** (Android POS terminal or Soundbox)
- **Internet connectivity** on merchant system (Wi-Fi/Mobile Hotspot)
- **TLS 1.2** protocol support for API communication

### 2. Configuration
1. Navigate to **Razorpay POS** from the dashboard
2. Click the **Settings** icon to open configuration
3. Enter your credentials:
   - **App Key**: Provided by Razorpay
   - **Username**: Merchant username
   - **Device ID**: POS device serial number
   - **Device Type**: Android POS or Soundbox
   - **Account Label**: For multi-TID scenarios (optional)

### 3. Testing
- Use the **Test Config** button to verify device connectivity
- Test with small amounts in demo mode
- Use predefined test amounts to simulate different scenarios

## API Integration Details

### Payment Initiation
```dart
final transaction = await RazorpayPOSService().initiatePayment(
  amount: 100.0,
  deviceId: 'YOUR_DEVICE_ID',
  deviceType: RazorpayPOSConfig.deviceTypeAndroid,
  paymentMode: RazorpayPOSConfig.paymentModeCard,
  customerName: 'John Doe',
  customerMobile: '9876543210',
);
```

### Transaction Monitoring
```dart
RazorpayPOSService().transactionStream.listen((transaction) {
  if (transaction.isCompleted) {
    if (transaction.isSuccessful) {
      // Handle successful payment
      print('Payment successful: ${transaction.finalStatus?.txnId}');
    } else {
      // Handle failed payment
      print('Payment failed: ${transaction.errorMessage}');
    }
  }
});
```

### DQR Payment
```dart
final transaction = await RazorpayPOSService().initiateDQRPayment(
  amount: 50.0,
  deviceId: 'YOUR_SOUNDBOX_ID',
  customerName: 'Jane Smith',
);
```

## Configuration Constants

### Environment Settings
```dart
// Switch between demo and production
static const bool isDemoMode = true;

// API URLs are automatically selected based on environment
static String get payUrl => isDemoMode ? demoPay : prodPay;
```

### Payment Modes
```dart
static const String paymentModeAll = 'ALL';
static const String paymentModeCard = 'CARD';
static const String paymentModeUPI = 'UPI';
static const String paymentModeCash = 'CASH';
static const String paymentModeBharatQR = 'BHARATQR';
static const String paymentModeEMI = 'EMI';
```

### Device Types
```dart
static const String deviceTypeAndroid = 'ezetap_android';
static const String deviceTypeSoundbox = 'razorpay_pos_soundbox';
```

## Error Handling

### Common Error Codes
- **EZETAP_0000382**: Device not found - Check device ID
- **EZETAP_0000385**: Device not connected - Check network
- **EZETAP_0000039**: Invalid amount
- **EZETAP_0000623**: Device busy with pending notification

### Error Resolution
```dart
static String getErrorMessage(String? errorCode) {
  return RazorpayPOSConfig.errorCodes[errorCode] ?? 'Unknown error';
}
```

## Testing Scenarios

### Demo Mode Test Amounts
The implementation includes predefined test amounts for simulating various scenarios:

```dart
// Test amounts for different scenarios
408.0  => 'Payment Gateway Takes 3 minutes to respond'
501.0  => 'Call Issuer'
531.0  => 'Declined'
599.0  => 'Session Expired'
```

### Best Practices
1. **Status Check Timing**: 
   - Wait 30 seconds before first status check
   - Check every 10 seconds for up to 150 seconds
   - Cancel transaction after timeout

2. **Transaction Lifecycle**:
   ```dart
   // 1. Initiate payment
   // 2. Monitor status changes
   // 3. Handle completion or timeout
   // 4. Process final result
   ```

## Security Considerations

### Data Protection
- **App Keys** stored securely using SharedPreferences
- **TLS 1.2+** encryption for all API communications
- **PCI DSS compliance** for card transactions

### Network Requirements
- **Minimum TLS 1.2** protocol support
- **Stable internet connection** (Wi-Fi or Mobile Hotspot)
- **API endpoint accessibility** (demo.ezetap.com or www.ezetap.com)

## Multi-TID Support

### Account Labels
For merchants with multiple Terminal IDs (TIDs):
```dart
final transaction = await RazorpayPOSService().initiatePayment(
  amount: 100.0,
  deviceId: 'DEVICE_ID',
  accountLabel: 'AC1', // Routes to specific TID
  // ... other parameters
);
```

## Production Deployment

### Steps to Go Live
1. **Test thoroughly** in demo environment
2. **Procure production device** via bank/Razorpay
3. **Get production credentials** from Razorpay team
4. **Update configuration**:
   - Set `isDemoMode = false`
   - Update app key and credentials
   - Replace demo URLs with production URLs
5. **Perform test transactions** with small amounts
6. **Monitor initial transactions** closely

### Production Checklist
- [ ] Demo integration tested and validated
- [ ] Production device procured and configured
- [ ] Production credentials received
- [ ] App configuration updated
- [ ] Test transactions completed successfully
- [ ] Error handling verified
- [ ] Transaction monitoring setup

## Support and Troubleshooting

### Common Issues
1. **Device connectivity**: Check Wi-Fi/mobile data
2. **Invalid device ID**: Verify format (min 8 alphanumeric)
3. **API timeouts**: Check network stability
4. **Transaction failures**: Refer to error codes

### Getting Help
- **Integration support**: Contact Razorpay POS solution consultant
- **Technical issues**: pos-integrations@razorpay.com
- **Device issues**: Contact device procurement team

## Dependencies

### Required Packages
```yaml
dependencies:
  http: ^1.1.0           # API communication
  shared_preferences: ^2.2.2  # Settings storage
  uuid: ^4.2.1          # Unique ID generation
  dio: ^5.4.0           # HTTP client with interceptors
  qr_flutter: ^4.1.0    # QR code generation
```

## License

This implementation follows Razorpay POS integration guidelines and is designed for merchants with valid Razorpay POS agreements.

---

**Note**: This is a production-ready implementation that follows Razorpay's official documentation and best practices. Ensure you have proper merchant agreements and credentials before using in production.
