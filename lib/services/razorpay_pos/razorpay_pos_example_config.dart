/// Example configuration for Razorpay POS Integration
/// 
/// Copy this file and update the values according to your setup.
/// Make sure to keep your actual credentials secure and not commit them to version control.

class RazorpayPOSExampleConfig {
  // ============================================================================
  // IMPORTANT: Replace these values with your actual Razorpay POS credentials
  // ============================================================================
  
  /// Demo Environment Credentials
  static const String demoAppKey = 'YOUR_DEMO_APP_KEY_HERE';
  static const String demoUsername = 'YOUR_DEMO_USERNAME_HERE';
  static const String demoDeviceId = 'YOUR_DEMO_DEVICE_ID_HERE';
  
  /// Production Environment Credentials
  static const String prodAppKey = 'YOUR_PRODUCTION_APP_KEY_HERE';
  static const String prodUsername = 'YOUR_PRODUCTION_USERNAME_HERE';
  static const String prodDeviceId = 'YOUR_PRODUCTION_DEVICE_ID_HERE';
  
  /// Merchant Information
  static const String merchantName = 'Your Business Name';
  static const String merchantAddress = 'Your Business Address';
  static const String merchantContact = 'your-email@example.com';
  
  /// Device Configuration Examples
  /// 
  /// Android POS Device Example:
  /// - Device ID: '1850319432' (example)
  /// - Device Type: 'ezetap_android'
  /// 
  /// Soundbox Device Example:
  /// - Device ID: '38230908450035' (example)
  /// - Device Type: 'razorpay_pos_soundbox'
  
  /// Multi-TID Configuration (if applicable)
  static const Map<String, String> accountLabels = {
    'AC1': 'Main Counter',
    'AC2': 'Secondary Counter',
    // Add more account labels as needed
  };
  
  /// Test Scenarios for Demo Environment
  /// 
  /// Use these amounts in demo mode to test different scenarios:
  /// 
  /// Success Scenarios:
  /// - Any amount not in the predefined test list will simulate success
  /// 
  /// Error Scenarios:
  /// - 501.0 = Call Issuer
  /// - 531.0 = Declined
  /// - 534.0 = Suspected Card
  /// - 585.0 = Batch Not Found
  /// 
  /// Timeout Scenarios:
  /// - 408.0 = Payment Gateway Takes 3 minutes to respond
  /// - 666.0 = Payment Gateway takes 1.5 minutes to respond
  
  /// Sample Payment Request
  static Map<String, dynamic> getSamplePaymentRequest() {
    return {
      'amount': 100.0,
      'customerName': 'John Doe',
      'customerMobile': '9876543210',
      'customerEmail': 'john.doe@example.com',
      'description': 'Test Payment',
      'paymentMode': 'CARD', // or 'UPI', 'ALL', etc.
    };
  }
  
  /// Integration Checklist
  /// 
  /// Before going live, ensure you have:
  /// 
  /// ✅ Demo environment setup and tested
  /// ✅ Production credentials from Razorpay
  /// ✅ Physical POS device configured
  /// ✅ Network connectivity verified
  /// ✅ Test transactions completed successfully
  /// ✅ Error handling implemented
  /// ✅ Transaction monitoring setup
  /// ✅ Production environment variables configured
  /// 
  /// Contact Razorpay POS team for support:
  /// - Email: pos-integrations@razorpay.com
  /// - Documentation: Razorpay POS Integration Guide
}

/// Configuration Steps:
/// 
/// 1. Get Demo Credentials:
///    - Contact Razorpay solution consultant
///    - Provide business details for demo account creation
///    - Receive demo app key and device for testing
/// 
/// 2. Setup Demo Environment:
///    - Update RazorpayPOSConfig.isDemoMode = true
///    - Configure demo credentials in the app
///    - Test with demo device
/// 
/// 3. Go Live:
///    - Procure production device
///    - Get production credentials
///    - Update RazorpayPOSConfig.isDemoMode = false
///    - Update production credentials
///    - Test with small amounts
/// 
/// 4. Monitor:
///    - Set up transaction monitoring
///    - Implement error handling
///    - Monitor initial transactions closely

/// Security Best Practices:
/// 
/// ⚠️  Never commit real credentials to version control
/// ⚠️  Use environment variables for production
/// ⚠️  Implement proper error logging
/// ⚠️  Use HTTPS for all API communications
/// ⚠️  Validate all input parameters
/// ⚠️  Implement transaction timeouts
/// ⚠️  Store sensitive data securely
