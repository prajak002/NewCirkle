import 'package:flutter/services.dart';

class NeptuneService {
  static const _channel = MethodChannel('com.example.cirmle_rfid_pos/neptune_card');

  /// Read card UID when card is tapped
  static Future<String?> readCardUID() async {
    try {
      final uid = await _channel.invokeMethod<String>('readCardUID');
      return uid;
    } catch (e) {
      print('Error reading card UID: $e');
      return null;
    }
  }

  /// Start continuous card detection
  static Future<bool> startCardDetection() async {
    try {
      final result = await _channel.invokeMethod<bool>('startCardDetection');
      return result ?? false;
    } catch (e) {
      print('Error starting card detection: $e');
      return false;
    }
  }

  /// Stop card detection
  static Future<bool> stopCardDetection() async {
    try {
      final result = await _channel.invokeMethod<bool>('stopCardDetection');
      return result ?? false;
    } catch (e) {
      print('Error stopping card detection: $e');
      return false;
    }
  }

  /// Initialize Neptune SDK
  static Future<bool> initializeSDK() async {
    try {
      final result = await _channel.invokeMethod<bool>('initializeSDK');
      return result ?? false;
    } catch (e) {
      print('Error initializing Neptune SDK: $e');
      return false;
    }
  }

  /// Get device serial number
  static Future<String?> getDeviceSerial() async {
    try {
      final serial = await _channel.invokeMethod<String>('getDeviceSerial');
      return serial;
    } catch (e) {
      print('Error getting device serial: $e');
      return null;
    }
  }

  /// Write data to card
  static Future<bool> writeToCard({
    required String uid,
    required String data,
    int block = 4, // Default block for user data
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('writeToCard', {
        'uid': uid,
        'data': data,
        'block': block,
      });
      return result ?? false;
    } catch (e) {
      print('Error writing to card: $e');
      return false;
    }
  }

  /// Read data from card
  static Future<String?> readFromCard({
    required String uid,
    int block = 4, // Default block for user data
  }) async {
    try {
      final data = await _channel.invokeMethod<String>('readFromCard', {
        'uid': uid,
        'block': block,
      });
      return data;
    } catch (e) {
      print('Error reading from card: $e');
      return null;
    }
  }

  /// Check if Neptune device is connected
  static Future<bool> isDeviceConnected() async {
    try {
      final result = await _channel.invokeMethod<bool>('isDeviceConnected');
      return result ?? false;
    } catch (e) {
      print('Error checking device connection: $e');
      return false;
    }
  }

  /// Set up card detection listener
  static void setCardDetectionListener(Function(String uid) onCardDetected, Function(String error) onError) {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onCardDetected':
          final uid = call.arguments as String?;
          if (uid != null) {
            onCardDetected(uid);
          }
          break;
        case 'onCardError':
          final error = call.arguments as String?;
          if (error != null) {
            onError(error);
          }
          break;
      }
    });
  }
}
