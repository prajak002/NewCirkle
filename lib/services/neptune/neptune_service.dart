import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'mock_neptune_service.dart';

class NeptuneService {
  // Singleton pattern
  static final NeptuneService _instance = NeptuneService._internal();
  factory NeptuneService() => _instance;
  NeptuneService._internal();

  // Method channel for communication with native code
  static const _channel = MethodChannel('com.example.cirmle_rfid_pos/neptune_card');
  
  // Mock service for testing without hardware
  final MockNeptuneService _mockService = MockNeptuneService();
  
  // Control flag for using mock vs. real implementation
  bool _useMockImplementation = true; // Set to false for production
  
  // Stream controllers for real hardware implementation
  final StreamController<String?> _cardDetectionController = StreamController<String?>.broadcast();
  Stream<String?> get cardDetectionStream => _useMockImplementation 
      ? _mockService.cardDetectionStream 
      : _cardDetectionController.stream;

  /// Check if using mock implementation
  bool get isMockMode => _useMockImplementation;
  
  /// Toggle between mock and real implementation
  set useMockImplementation(bool value) {
    _useMockImplementation = value;
  }

  /// Initialize Neptune SDK
  Future<bool> initialize() async {
    if (_useMockImplementation) {
      return _mockService.initialize();
    }
    
    try {
      final result = await _channel.invokeMethod<bool>('initializeSDK');
      return result ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Neptune SDK: $e');
      }
      return false;
    }
  }

  /// Read card UID when card is tapped
  Future<String?> readCardUID() async {
    if (_useMockImplementation) {
      return _mockService.readCardUID();
    }
    
    try {
      final uid = await _channel.invokeMethod<String>('readCardUID');
      return uid;
    } catch (e) {
      if (kDebugMode) {
        print('Error reading card UID: $e');
      }
      return null;
    }
  }

  /// Start continuous card detection
  Future<bool> startCardDetection() async {
    if (_useMockImplementation) {
      return _mockService.startCardDetection();
    }
    
    try {
      final result = await _channel.invokeMethod<bool>('startCardDetection');
      return result ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('Error starting card detection: $e');
      }
      return false;
    }
  }

  /// Stop card detection
  Future<bool> stopCardDetection() async {
    if (_useMockImplementation) {
      return _mockService.stopCardDetection();
    }
    
    try {
      final result = await _channel.invokeMethod<bool>('stopCardDetection');
      return result ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping card detection: $e');
      }
      return false;
    }
  }
  
  /// Get a stream of card detection events
  Stream<String?> detectCard() {
    if (_useMockImplementation) {
      return _mockService.cardDetectionStream;
    }
    
    // Set up the method channel listener if not using mock
    _setupCardDetectionListener();
    return _cardDetectionController.stream;
  }
  
  /// Set up event channel for card detection
  void _setupCardDetectionListener() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onCardDetected') {
        final String? cardUID = call.arguments as String?;
        _cardDetectionController.add(cardUID);
      }
      return null;
    });
  }
  
  /// Clean up resources
  void dispose() {
    if (_useMockImplementation) {
      _mockService.dispose();
    }
    _cardDetectionController.close();
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
