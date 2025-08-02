class RazorpayPOSConfig {
  // Environment Configuration
  static const bool isDemoMode = true; // Set to false for production
  
  // Demo URLs
  static const String demoBaseUrl = 'https://demo.ezetap.com/api/3.0/p2padapter';
  static const String demoPay = '$demoBaseUrl/pay';
  static const String demoStatus = '$demoBaseUrl/status';
  static const String demoCancel = '$demoBaseUrl/cancel';
  
  // Production URLs
  static const String prodBaseUrl = 'https://www.ezetap.com/api/3.0/p2padapter';
  static const String prodPay = '$prodBaseUrl/pay';
  static const String prodStatus = '$prodBaseUrl/status';
  static const String prodCancel = '$prodBaseUrl/cancel';
  
  // Current URLs based on environment
  static String get payUrl => isDemoMode ? demoPay : prodPay;
  static String get statusUrl => isDemoMode ? demoStatus : prodStatus;
  static String get cancelUrl => isDemoMode ? demoCancel : prodCancel;
  
  // App Configuration
  static const String demoAppKey = 'YOUR_DEMO_APP_KEY'; // Replace with actual demo app key
  static const String prodAppKey = 'YOUR_PROD_APP_KEY'; // Replace with actual production app key
  static String get appKey => isDemoMode ? demoAppKey : prodAppKey;
  
  // Default Username (can be customized per merchant)
  static const String defaultUsername = '4444001234';
  
  // Payment Modes
  static const String paymentModeAll = 'ALL';
  static const String paymentModeCard = 'CARD';
  static const String paymentModeCash = 'CASH';
  static const String paymentModeUPI = 'UPI';
  static const String paymentModeBharatQR = 'BHARATQR';
  static const String paymentModeEMI = 'EMI';
  
  // Device Types
  static const String deviceTypeAndroid = 'ezetap_android';
  static const String deviceTypeSoundbox = 'razorpay_pos_soundbox';
  
  // Transaction Status
  static const String statusAuthorized = 'AUTHORIZED';
  static const String statusFailed = 'FAILED';
  static const String statusRefunded = 'REFUNDED';
  static const String statusVoided = 'VOIDED';
  static const String statusExpired = 'EXPIRED';
  
  // Message Codes
  static const String messageCodeDeviceReceived = 'P2P_DEVICE_RECEIVED';
  static const String messageCodeDeviceSent = 'P2P_DEVICE_SENT';
  static const String messageCodeStatusQueued = 'P2P_STATUS_QUEUED';
  static const String messageCodeStatusExpired = 'P2P_STATUS_IN_EXPIRED';
  static const String messageCodeDeviceTxnDone = 'P2P_DEVICE_TXN_DONE';
  static const String messageCodeStatusUnknown = 'P2P_STATUS_UNKNOWN';
  static const String messageCodeDeviceCanceled = 'P2P_DEVICE_CANCELED';
  static const String messageCodeCanceledFromExternal = 'P2P_STATUS_IN_CANCELED_FROM_EXTERNAL_SYSTEM';
  
  // Timeouts (in seconds)
  static const int initialStatusCheckDelay = 30;
  static const int statusCheckInterval = 10;
  static const int maxStatusCheckDuration = 150;
  static const int apiTimeout = 30;
  
  // Currency
  static const String defaultCurrency = 'INR';
  
  // Error Codes
  static const Map<String, String> errorCodes = {
    'EZETAP_0000382': 'Device not found - Pass correct device serial number',
    'EZETAP_0000385': 'Device is not in the Network - Check WiFi connectivity',
    'EZETAP_0000039': 'Payment amount unsupported - Pass correct value for amount',
    'EZETAP_0000050': 'Transaction amount greater than Limit',
    'EZETAP_0000162': 'Transaction amount less than Limit',
    'EZETAP_0000048': 'Payment tip not enabled',
    'EZETAP_0000148': 'Invalid Org, device does not belong to the org',
    'EZETAP_0000047': 'Payment tip amount error',
    'EZETAP_0000387': 'ExternalRefNumber field is empty',
    'EZETAP_6000001': 'No such payment mode exists',
    'EZETAP_0000623': 'Device is busy with pending notification',
    'EZETAP_0000381': 'Android FCM token not found',
    'EZETAP_0000384': 'Firebase FCM error',
    'EZETAP_0000383': 'Notification not found for this refNumber',
  };
  
  // Test Amounts for Error Simulation
  static const Map<double, String> testAmounts = {
    408.0: 'Payment Gateway Takes 3 minutes to respond',
    410.0: 'Timeout',
    501.0: 'Call Issuer',
    502.0: 'Call Referral',
    504.0: 'Pick up',
    505.0: 'Do not Honor',
    508.0: 'Honor with Id',
    512.0: 'Invalid Transaction',
    513.0: 'Invalid Amount',
    514.0: 'Invalid Card Number',
    515.0: 'No such Issuer',
    519.0: 'Try after 1 min',
    522.0: 'Susp Malfunction',
    523.0: 'Trans Fee Error',
    526.0: 'Duplicate Record',
    531.0: 'Declined',
    533.0: 'Expired Card',
    534.0: 'Suspected Card',
    535.0: 'Contact Acquirer',
    536.0: 'Restricted Card',
    539.0: 'No Credit Account',
    542.0: 'Timeout',
    556.0: 'No Card Record',
    561.0: 'Above Amount Limit',
    585.0: 'Batch Not Found',
    590.0: 'Cutoff in Process',
    591.0: 'Host Unavailable',
    592.0: 'Routing Problem',
    596.0: 'Err – Invalid Message',
    598.0: 'Kx Required',
    599.0: 'Session Expired',
    666.0: 'Payment Gateway takes 1.5 minutes to respond',
  };
}
