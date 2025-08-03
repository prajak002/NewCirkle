import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/card_service.dart';
import '../../services/api_service.dart';

class CardPaymentScreen extends StatefulWidget {
  const CardPaymentScreen({super.key});

  @override
  State<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends State<CardPaymentScreen> with SingleTickerProviderStateMixin {
  bool _isCardReaderInitialized = false;
  bool _isDetecting = false;
  String? _cardId;
  String? _errorMessage;
  bool _isProcessing = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  StreamSubscription? _cardDetectionSubscription;
  StreamSubscription? _cardErrorSubscription;
  
  final CardService _cardService = CardService();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initializeCardReader();
  }

  Future<void> _initializeCardReader() async {
    try {
      final isInitialized = await _cardService.initializeCardReader();
      
      if (mounted) {
        setState(() {
          _isCardReaderInitialized = isInitialized;
          if (!isInitialized) {
            _errorMessage = 'Failed to initialize card reader';
          }
        });
      }

      if (isInitialized) {
        _startListeningForCards();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCardReaderInitialized = false;
          _errorMessage = 'Error initializing card reader: ${e.toString()}';
        });
      }
    }
  }

  void _startListeningForCards() {
    _cardDetectionSubscription = _cardService.onCardDetected.listen((cardId) {
      if (mounted && !_isProcessing) {
        setState(() {
          _cardId = cardId;
          _isDetecting = false;
        });
        
        _processCardPayment(cardId);
      }
    });

    _cardErrorSubscription = _cardService.onCardError.listen((error) {
      if (mounted) {
        setState(() {
          _errorMessage = error;
        });
      }
    });
  }

  Future<void> _startCardDetection() async {
    if (!_isCardReaderInitialized) {
      await _initializeCardReader();
      if (!_isCardReaderInitialized) return;
    }

    try {
      final started = await _cardService.startCardDetection();
      
      if (mounted) {
        setState(() {
          _isDetecting = started;
          if (!started) {
            _errorMessage = 'Failed to start card detection';
          } else {
            _errorMessage = null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDetecting = false;
          _errorMessage = 'Error starting card detection: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _stopCardDetection() async {
    try {
      await _cardService.stopCardDetection();
      
      if (mounted) {
        setState(() {
          _isDetecting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error stopping card detection: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _processCardPayment(String cardId) async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // In a real app, you would get these details from previous screens
      // For this example, we're using mock values
      final orderId = 'mock_order_${DateTime.now().millisecondsSinceEpoch}';
      final amount = 100;  // ₹1.00 in paise/cents
      
      final result = await _apiService.processCardTopUp(
        cardUid: cardId,
        amount: amount,
        transactionId: orderId,
      );

      if (mounted) {
        if (result) {
          // Show success and navigate to receipt/confirmation
          _showSuccessDialog(cardId, amount / 100);
        } else {
          setState(() {
            _isProcessing = false;
            _errorMessage = 'Payment processing failed';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'Error processing payment: ${e.toString()}';
        });
      }
    }
  }

  void _showSuccessDialog(String cardId, double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            SizedBox(width: 8),
            Text('Payment Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Card ID: ${cardId.substring(0, 4)}...${cardId.substring(cardId.length - 4)}'),
            SizedBox(height: 8),
            Text('Amount: ₹${amount.toStringAsFixed(2)}'),
            SizedBox(height: 8),
            Text('Time: ${DateTime.now().toString().substring(0, 19)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _cardId = null;
                _isProcessing = false;
              });
              _startCardDetection();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1976D2),
            ),
            child: Text('Next Payment'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _cardDetectionSubscription?.cancel();
    _cardErrorSubscription?.cancel();
    _stopCardDetection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Card Payment'),
        backgroundColor: Color(0xFF1976D2),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header area with status
            Container(
              padding: EdgeInsets.all(16),
              color: Color(0xFF1976D2).withOpacity(0.1),
              child: Row(
                children: [
                  Icon(
                    _isCardReaderInitialized
                        ? Icons.check_circle
                        : Icons.error_outline,
                    color: _isCardReaderInitialized ? Colors.green : Colors.red,
                  ),
                  SizedBox(width: 8),
                  Text(
                    _isCardReaderInitialized
                        ? 'Card Reader Ready'
                        : 'Card Reader Not Initialized',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _isCardReaderInitialized ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),

            // Error message if any
            if (_errorMessage != null)
              Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    ),
                  ],
                ),
              ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Card detection animation
                      if (_isDetecting)
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF1976D2).withOpacity(0.2),
                                ),
                                child: Icon(
                                  Icons.contactless,
                                  size: 100,
                                  color: Color(0xFF1976D2),
                                ),
                              ),
                            );
                          },
                        )
                      else if (_cardId != null && _isProcessing)
                        Column(
                          children: [
                            Icon(
                              Icons.credit_card,
                              size: 100,
                              color: Color(0xFF1976D2),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Card Detected!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1976D2),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Card ID: ${_cardId!.substring(0, 4)}...${_cardId!.substring(_cardId!.length - 4)}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 24),
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Processing payment...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            Icon(
                              Icons.contactless_outlined,
                              size: 100,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 24),
                            Text(
                              'Ready to Scan Card',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap the button below to start scanning',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      
                      SizedBox(height: 48),
                      
                      // Action button
                      if (!_isProcessing)
                        ElevatedButton.icon(
                          onPressed: _isDetecting ? _stopCardDetection : _startCardDetection,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isDetecting ? Colors.red : Color(0xFF1976D2),
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(_isDetecting ? Icons.stop : Icons.play_arrow),
                          label: Text(
                            _isDetecting ? 'Stop Detection' : 'Start Detection',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
