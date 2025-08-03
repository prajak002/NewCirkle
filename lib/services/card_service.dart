import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class CardService {
  static const MethodChannel _channel = MethodChannel('com.example.cirmle_rfid_pos/neptune_card');
  
  // Singleton pattern
  static final CardService _instance = CardService._internal();
  factory CardService() => _instance;
  CardService._internal() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  // Stream controllers for card events
  final _cardDetectedController = StreamController<String>.broadcast();
  final _cardErrorController = StreamController<String>.broadcast();
  
  // Streams that UI can listen to
  Stream<String> get onCardDetected => _cardDetectedController.stream;
  Stream<String> get onCardError => _cardErrorController.stream;

  // Handle method calls from native side
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onCardDetected':
        final String cardId = call.arguments;
        _cardDetectedController.add(cardId);
        break;
      case 'onCardError':
        final String error = call.arguments;
        _cardErrorController.add(error);
        break;
    }
    return null;
  }

  // Initialize card reader SDK
  Future<bool> initializeCardReader() async {
    try {
      final result = await _channel.invokeMethod<bool>('initializeSDK');
      return result ?? false;
    } catch (e) {
      debugPrint('Initialize card reader error: $e');
      return false;
    }
  }

  // Start card detection
  Future<bool> startCardDetection() async {
    try {
      final result = await _channel.invokeMethod<bool>('startCardDetection');
      return result ?? false;
    } catch (e) {
      debugPrint('Start card detection error: $e');
      return false;
    }
  }

  // Stop card detection
  Future<bool> stopCardDetection() async {
    try {
      final result = await _channel.invokeMethod<bool>('stopCardDetection');
      return result ?? false;
    } catch (e) {
      debugPrint('Stop card detection error: $e');
      return false;
    }
  }

  // Read card UID (single read)
  Future<String?> readCardUID() async {
    try {
      final result = await _channel.invokeMethod<String>('readCardUID');
      return result;
    } catch (e) {
      debugPrint('Read card UID error: $e');
      return null;
    }
  }

  // Get device information
  Future<Map<String, dynamic>?> getDeviceInfo() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('getDeviceInfo');
      if (result != null) {
        return Map<String, dynamic>.from(result);
      }
      return null;
    } catch (e) {
      debugPrint('Get device info error: $e');
      return null;
    }
  }

  // Clean up resources
  Future<void> dispose() async {
    await stopCardDetection();
    await _channel.invokeMethod<void>('cleanup');
    await _cardDetectedController.close();
    await _cardErrorController.close();
  }
}
