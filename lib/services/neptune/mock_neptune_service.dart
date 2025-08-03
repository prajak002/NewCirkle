import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

/// Mock implementation of Neptune card reader service for testing without hardware
class MockNeptuneService {
  static final MockNeptuneService _instance = MockNeptuneService._internal();
  
  factory MockNeptuneService() => _instance;
  
  MockNeptuneService._internal();

  // Simulation control flags
  bool _isInitialized = false;
  bool _isDetecting = false;
  Timer? _detectionTimer;
  
  // Stream controllers for card detection events
  final _cardDetectionController = StreamController<String?>.broadcast();
  Stream<String?> get cardDetectionStream => _cardDetectionController.stream;
  
  // Configurable mock settings
  int detectionDelayMs = 2000; // Simulate card detection after 2 seconds
  double failureRate = 0.1;    // 10% chance of failure for realistic testing
  
  /// Initialize the mock Neptune SDK
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    // Simulate initialization delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Random chance of failure for testing error handling
    if (_shouldFail(0.05)) {
      if (kDebugMode) {
        print('[MockNeptune] Failed to initialize SDK');
      }
      _isInitialized = false;
      return false;
    }
    
    _isInitialized = true;
    if (kDebugMode) {
      print('[MockNeptune] SDK initialized successfully');
    }
    return true;
  }
  
  /// Simulate reading a card UID (one-time detection)
  Future<String?> readCardUID() async {
    if (!_isInitialized) return null;
    
    // Simulate card detection delay
    await Future.delayed(Duration(milliseconds: detectionDelayMs));
    
    // Random chance of failure
    if (_shouldFail(failureRate)) {
      if (kDebugMode) {
        print('[MockNeptune] Failed to read card');
      }
      return null;
    }
    
    // Generate a mock card UID
    final cardUID = _generateMockCardUID();
    if (kDebugMode) {
      print('[MockNeptune] Card detected: $cardUID');
    }
    return cardUID;
  }
  
  /// Start continuous card detection simulation
  Future<bool> startCardDetection() async {
    if (!_isInitialized) return false;
    if (_isDetecting) return true;
    
    _isDetecting = true;
    _detectionTimer = Timer.periodic(
      Duration(milliseconds: detectionDelayMs), 
      (_) => _simulateCardDetection()
    );
    
    if (kDebugMode) {
      print('[MockNeptune] Started card detection');
    }
    return true;
  }
  
  /// Stop continuous card detection simulation
  Future<bool> stopCardDetection() async {
    if (!_isDetecting) return true;
    
    _detectionTimer?.cancel();
    _detectionTimer = null;
    _isDetecting = false;
    
    if (kDebugMode) {
      print('[MockNeptune] Stopped card detection');
    }
    return true;
  }
  
  /// Dispose resources
  void dispose() {
    stopCardDetection();
    _cardDetectionController.close();
  }
  
  /// Simulate a card detection event
  void _simulateCardDetection() {
    // Random chance of failure
    if (_shouldFail(failureRate)) {
      if (kDebugMode) {
        print('[MockNeptune] Card detection failed');
      }
      _cardDetectionController.add(null);
      return;
    }
    
    // Generate a mock card UID
    final cardUID = _generateMockCardUID();
    if (kDebugMode) {
      print('[MockNeptune] Card detected: $cardUID');
    }
    _cardDetectionController.add(cardUID);
    
    // Automatically stop detection after success (like real hardware would)
    stopCardDetection();
  }
  
  /// Generate a realistic-looking mock card UID
  String _generateMockCardUID() {
    const chars = '0123456789ABCDEF';
    final random = Random();
    
    // Format: "XX:XX:XX:XX" where X is a hex digit
    String uid = '';
    for (int i = 0; i < 4; i++) {
      if (i > 0) uid += ':';
      for (int j = 0; j < 2; j++) {
        uid += chars[random.nextInt(chars.length)];
      }
    }
    
    return uid;
  }
  
  /// Utility to simulate failures with a given probability
  bool _shouldFail(double probability) {
    return Random().nextDouble() < probability;
  }
}
