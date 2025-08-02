import 'package:shared_preferences/shared_preferences.dart';
import 'razorpay_pos_config.dart';

class RazorpayPOSSettings {
  static const String _keyAppKey = 'razorpay_pos_app_key';
  static const String _keyUsername = 'razorpay_pos_username';
  static const String _keyDeviceId = 'razorpay_pos_device_id';
  static const String _keyDeviceType = 'razorpay_pos_device_type';
  static const String _keyAccountLabel = 'razorpay_pos_account_label';
  static const String _keyMerchantName = 'razorpay_pos_merchant_name';
  static const String _keyIsConfigured = 'razorpay_pos_is_configured';

  static SharedPreferences? _prefs;

  static Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // App Key Management
  static Future<void> setAppKey(String appKey) async {
    await _initPrefs();
    await _prefs!.setString(_keyAppKey, appKey);
  }

  static Future<String> getAppKey() async {
    await _initPrefs();
    return _prefs!.getString(_keyAppKey) ?? RazorpayPOSConfig.appKey;
  }

  // Username Management
  static Future<void> setUsername(String username) async {
    await _initPrefs();
    await _prefs!.setString(_keyUsername, username);
  }

  static Future<String> getUsername() async {
    await _initPrefs();
    return _prefs!.getString(_keyUsername) ?? RazorpayPOSConfig.defaultUsername;
  }

  // Device Configuration
  static Future<void> setDeviceId(String deviceId) async {
    await _initPrefs();
    await _prefs!.setString(_keyDeviceId, deviceId);
  }

  static Future<String?> getDeviceId() async {
    await _initPrefs();
    return _prefs!.getString(_keyDeviceId);
  }

  static Future<void> setDeviceType(String deviceType) async {
    await _initPrefs();
    await _prefs!.setString(_keyDeviceType, deviceType);
  }

  static Future<String> getDeviceType() async {
    await _initPrefs();
    return _prefs!.getString(_keyDeviceType) ?? RazorpayPOSConfig.deviceTypeAndroid;
  }

  // Account Label
  static Future<void> setAccountLabel(String accountLabel) async {
    await _initPrefs();
    await _prefs!.setString(_keyAccountLabel, accountLabel);
  }

  static Future<String?> getAccountLabel() async {
    await _initPrefs();
    return _prefs!.getString(_keyAccountLabel);
  }

  // Merchant Name
  static Future<void> setMerchantName(String merchantName) async {
    await _initPrefs();
    await _prefs!.setString(_keyMerchantName, merchantName);
  }

  static Future<String?> getMerchantName() async {
    await _initPrefs();
    return _prefs!.getString(_keyMerchantName);
  }

  // Configuration Status
  static Future<void> setConfigured(bool isConfigured) async {
    await _initPrefs();
    await _prefs!.setBool(_keyIsConfigured, isConfigured);
  }

  static Future<bool> isConfigured() async {
    await _initPrefs();
    return _prefs!.getBool(_keyIsConfigured) ?? false;
  }

  // Save Complete Configuration
  static Future<void> saveConfiguration({
    required String appKey,
    required String username,
    required String deviceId,
    required String deviceType,
    String? accountLabel,
    String? merchantName,
  }) async {
    await setAppKey(appKey);
    await setUsername(username);
    await setDeviceId(deviceId);
    await setDeviceType(deviceType);
    if (accountLabel != null) await setAccountLabel(accountLabel);
    if (merchantName != null) await setMerchantName(merchantName);
    await setConfigured(true);
  }

  // Get Complete Configuration
  static Future<Map<String, dynamic>> getConfiguration() async {
    return {
      'appKey': await getAppKey(),
      'username': await getUsername(),
      'deviceId': await getDeviceId(),
      'deviceType': await getDeviceType(),
      'accountLabel': await getAccountLabel(),
      'merchantName': await getMerchantName(),
      'isConfigured': await isConfigured(),
    };
  }

  // Clear All Settings
  static Future<void> clearConfiguration() async {
    await _initPrefs();
    await _prefs!.remove(_keyAppKey);
    await _prefs!.remove(_keyUsername);
    await _prefs!.remove(_keyDeviceId);
    await _prefs!.remove(_keyDeviceType);
    await _prefs!.remove(_keyAccountLabel);
    await _prefs!.remove(_keyMerchantName);
    await _prefs!.setBool(_keyIsConfigured, false);
  }
}
