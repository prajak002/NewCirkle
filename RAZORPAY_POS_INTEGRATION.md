# Razorpay POS Integration - Complete Implementation Guide

## Overview

This project implements a comprehensive Razorpay POS integration solution with support for both HTTP API-based integration and native Android SDK integration. The implementation covers all major payment modes including Card, UPI, and Cash payments with complete transaction lifecycle management.

## Table of Contents

1. [POS Bridge Integration](#pos-bridge-integration)
2. [DQR (Dynamic QR) Solution](#dqr-dynamic-qr-solution)
3. [Android SDK Integration](#android-sdk-integration)
4. [Setup and Configuration](#setup-and-configuration)
5. [Usage Instructions](#usage-instructions)
6. [API Reference](#api-reference)
7. [Troubleshooting](#troubleshooting)

## Architecture

### Core Components

1. **HTTP API Layer** (`lib/models/razorpay_pos_*.dart`)
   - Configuration management
   - Data models for requests/responses
   - Service layer for API communication
   - Persistent settings storage

2. **Native SDK Integration** (`android/` and `lib/models/razorpay_native_sdk.dart`)
   - Method channel communication
   - Native Android SDK wrapper
   - Production-ready payment processing

3. **UI Layer** (`lib/screens/`)
   - Multiple payment screens for different scenarios
   - Real-time transaction monitoring
   - Configuration and setup screens

## POS Bridge Integration

### Features
- **Payment Modes**: CARD, UPI, CASH, ALL
- **Transaction Management**: Initiate, monitor, cancel payments
- **Status Polling**: Automatic status checking with configurable intervals
- **Test Scenarios**: Pre-configured test amounts for different scenarios

### API Endpoints
```
Demo: https://demo.ezetap.com/api/3.0/
Production: https://api.ezetap.com/api/3.0/
```

### Key Files
- `razorpay_pos_config.dart` - Environment and API configuration
- `razorpay_pos_models.dart` - Request/response data models
- `razorpay_pos_service.dart` - Core service implementation
- `razorpay_pos_settings.dart` - Persistent configuration storage

### Sample Payment Request
```dart
final paymentRequest = PaymentRequest(
  mode: 'CARD',
  amount: 100.0,
  externalRefNumber: 'REF_123',
  customerReceiptFlag: true,
  merchantReceiptFlag: true,
);

final response = await razorpayPOSService.makePayment(paymentRequest);
```

## DQR (Dynamic QR) Solution

### Features
- **QR Code Generation**: Dynamic QR codes for UPI payments
- **Real-time Updates**: Live transaction status monitoring
- **Custom Styling**: Branded QR code display
- **Timeout Handling**: Automatic expiry management

### Implementation
```dart
// Generate DQR payment
final dqrRequest = PaymentRequest(
  mode: 'UPI',
  amount: 250.0,
  externalRefNumber: 'DQR_456',
);

final response = await razorpayPOSService.makePayment(dqrRequest);
// QR code displayed using response.qrCodeData
```

### QR Code Display
- Uses `qr_flutter` package for QR rendering
- Supports custom colors and branding
- Responsive sizing for different screen sizes

## Android SDK Integration

### Native SDK Setup

1. **AAR Library**: `ezetapandroidsdk-3.28-68.aar`
   - Copied to `android/app/libs/`
   - Configured in `build.gradle.kts`

2. **Dependencies** (added to `android/app/build.gradle.kts`):
   ```kotlin
   implementation files('libs/ezetapandroidsdk-3.28-68.aar')
   implementation 'androidx.legacy:legacy-support-v4:1.0.0'
   implementation 'org.apache.httpcomponents:httpcore:4.4.10'
   implementation 'org.apache.httpcomponents:httpmime:4.5.6'
   ```

### Method Channel Implementation

1. **MainActivity.kt**: Bridge between Flutter and native SDK
2. **RazorpayPOSHandler.kt**: Native SDK wrapper with comprehensive method coverage
3. **razorpay_native_sdk.dart**: Flutter interface for native SDK calls

### Supported Operations
- SDK Initialization
- Payment Processing (Card/UPI/Cash)
- Transaction Void/Cancellation
- Receipt Printing
- Transaction Status Queries
- SDK Lifecycle Management

### Native SDK Usage
```dart
// Initialize SDK
final result = await RazorpayNativeSDK.initializeSDK(
  appKey: 'your_app_key',
  username: 'your_username',
  mode: 'DEMO', // or 'PROD'
  prepareDevice: true,
);

// Process card payment
final paymentResult = await RazorpayNativeSDK.cardPayment(
  amount: 100.0,
  externalRefNumber: 'TXN_123',
  customerName: 'John Doe',
);
```

## Setup and Configuration

### 1. Environment Configuration

Create configuration in `RazorpayPOSSetupScreen`:
- **App Key**: Your Razorpay POS app key
- **Username**: Registered username
- **Device ID**: Unique device identifier

### 2. Flutter Dependencies

Add to `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.1.0
  dio: ^5.4.0
  shared_preferences: ^2.2.2
  qr_flutter: ^4.1.0
```

### 3. Android Permissions

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
```

## Usage Instructions

### 1. Basic Payment Flow

1. **Configuration**: Set up app credentials in settings
2. **Payment Mode**: Select CARD/UPI/CASH/ALL
3. **Amount Entry**: Enter transaction amount
4. **Customer Details**: Optional customer information
5. **Process Payment**: Execute payment via HTTP API or native SDK
6. **Monitor Status**: Real-time transaction monitoring
7. **Receipt/Confirmation**: Print receipt or show confirmation

### 2. HTTP API Mode
- Use for testing and basic integration
- Supports all payment modes
- QR code generation for UPI
- Status polling and cancellation

### 3. Native SDK Mode
- Production-ready implementation
- Hardware integration support
- Receipt printing capabilities
- Enhanced error handling and callbacks

### 4. Switching Modes
The main POS screen allows real-time switching between HTTP API and Native SDK modes using the toggle button in the app bar.

## API Reference

### Configuration Classes

#### RazorpayPOSConfig
```dart
class RazorpayPOSConfig {
  static const String demoBaseUrl = 'https://demo.ezetap.com/api/3.0/';
  static const String prodBaseUrl = 'https://api.ezetap.com/api/3.0/';
  static const int timeoutSeconds = 30;
  static const int statusPollIntervalSeconds = 3;
}
```

#### Test Scenarios
- `0.01` - Success scenario
- `0.02` - Decline scenario  
- `0.03` - Timeout scenario
- `0.04` - Device error scenario

### Data Models

#### PaymentRequest
```dart
class PaymentRequest {
  final String mode;           // CARD, UPI, CASH, ALL
  final double amount;         // Transaction amount
  final String externalRefNumber; // External reference
  final bool customerReceiptFlag;
  final bool merchantReceiptFlag;
  // ... additional fields
}
```

#### PaymentResponse
```dart
class PaymentResponse {
  final String status;         // success, pending, failed
  final String? txnId;         // Transaction ID
  final String? qrCodeData;    // QR data for UPI
  final String message;        // Response message
  final Map<String, dynamic>? additionalData;
}
```

### Service Methods

#### RazorpayPOSService
```dart
// Make payment
Future<PaymentResponse> makePayment(PaymentRequest request);

// Check status
Future<StatusResponse> checkStatus(StatusRequest request);

// Cancel payment
Future<CancelResponse> cancelPayment(CancelRequest request);

// Status monitoring with automatic polling
Stream<StatusResponse> monitorTransaction(String txnId);
```

#### RazorpayNativeSDK
```dart
// SDK operations
static Future<Map<String, dynamic>> initializeSDK(...);
static Future<Map<String, dynamic>> makePayment(...);
static Future<Map<String, dynamic>> cardPayment(...);
static Future<Map<String, dynamic>> upiPayment(...);
static Future<Map<String, dynamic>> voidPayment(...);
static Future<Map<String, dynamic>> printReceipt(...);
```

## Screen Components

### 1. RazorpayPOSMainScreen
- **Purpose**: Primary interface combining HTTP API and Native SDK
- **Features**: Mode switching, payment processing, transaction management
- **Routes**: `/razorpay_pos_main`

### 2. RazorpayPOSScreen  
- **Purpose**: Navigation hub for different POS solutions
- **Features**: Access to POS Bridge, DQR, and settings
- **Routes**: `/razorpay_pos`

### 3. POSPaymentScreen
- **Purpose**: HTTP API-based payment processing
- **Features**: All payment modes, status monitoring, cancellation
- **Routes**: `/pos_payment`

### 4. DQRPaymentScreen
- **Purpose**: Dynamic QR code payments
- **Features**: QR generation, UPI integration, timeout handling
- **Routes**: `/dqr_payment`

### 5. RazorpayPOSSetupScreen
- **Purpose**: Configuration and settings management
- **Features**: Credential setup, environment selection, validation
- **Routes**: `/razorpay_pos_setup`

## Error Handling

### Common Error Codes
- `1001` - Invalid credentials
- `1002` - Network timeout
- `1003` - Device not ready
- `1004` - Transaction declined
- `1005` - Invalid amount

### Error Recovery
- Automatic retry mechanism for network failures
- Graceful fallback to HTTP API if SDK fails
- User-friendly error messages and guidance
- Comprehensive logging for debugging

## Testing

### Test Environment
- Use demo endpoints for testing
- Test amounts trigger specific scenarios
- Mock responses available for development
- Comprehensive error scenario coverage

### Test Credentials
Configure test credentials in setup screen:
- App Key: `your_demo_app_key`
- Username: `demo_user`
- Device ID: `test_device_001`

## Production Deployment

### Checklist
1. ✅ Update API endpoints to production URLs
2. ✅ Configure production app credentials
3. ✅ Enable native SDK for hardware integration
4. ✅ Test all payment modes thoroughly
5. ✅ Verify receipt printing functionality
6. ✅ Implement proper error handling
7. ✅ Set up transaction logging and monitoring

### Security Considerations
- Store credentials securely using SharedPreferences
- Implement proper session management
- Use HTTPS for all API communications
- Validate all transaction data
- Implement proper error logging without exposing sensitive data

## Troubleshooting

### Common Issues

1. **SDK Initialization Failed**
   - Verify app key and username
   - Check device connectivity
   - Ensure AAR library is properly configured

2. **Payment Processing Errors**
   - Check network connectivity
   - Verify amount format and limits
   - Ensure device is ready for payments

3. **QR Code Not Displaying**
   - Verify UPI integration
   - Check QR data format
   - Ensure proper UI rendering

4. **Status Polling Issues**
   - Check polling interval configuration
   - Verify transaction ID format
   - Monitor network stability

### Debug Logs
Enable debug logging in development:
```dart
RazorpayPOSConfig.enableDebugLogs = true;
```

### Support Resources
- Razorpay POS Documentation
- Native SDK Integration Guide
- Flutter Method Channel Documentation
- Community Support Forums

## Conclusion

This comprehensive Razorpay POS integration provides a complete payment solution suitable for both development and production environments. The dual-mode architecture ensures flexibility while maintaining production readiness through native SDK integration.

The implementation follows Flutter best practices and provides extensive error handling, testing capabilities, and user-friendly interfaces for seamless payment processing across multiple payment modes.
