# Neptune Card Reader Integration Guide

## Overview

This guide provides comprehensive instructions for integrating Neptune card reader functionality with your Flutter application. The implementation supports card detection, reading card UIDs, processing payments, and managing card transactions through backend API calls.

## Architecture

### Components Overview

1. **Flutter Service Layer** (`lib/services/neptune/`)
   - `NeptuneService` - Flutter interface for Neptune SDK communication
   - Method channel communication with native Android code

2. **Native Android Integration** (`android/app/src/main/kotlin/`)
   - `NeptuneCardHandler.kt` - Native SDK wrapper
   - `MainActivity.kt` - Method channel bridge
   - Integration with Neptune SDK libraries

3. **Backend Integration** (`lib/services/`)
   - `CardTransactionService` - API calls for payment processing
   - Card balance management and transaction history

4. **Data Models** (`lib/models/`)
   - `CardInfo` - Card detection data
   - `CardTransaction` - Payment transaction data  
   - `CardBalance` - Card balance information

5. **UI Layer** (`lib/screens/cards/`)
   - `NeptuneCardPaymentScreen` - Complete payment interface
   - Real-time card detection and payment processing

## Setup Instructions

### 1. Neptune SDK Setup

#### Step 1: Copy Neptune SDK Files
Extract your Neptune SDK (NeptuneLiteApi_V4.15.00_20250606) and copy the required files:

```bash
# Copy AAR files to Android libs directory
mkdir -p android/app/libs
cp path/to/neptune/sdk/*.aar android/app/libs/
```

#### Step 2: Update Android Build Configuration

Add to `android/app/build.gradle.kts`:

```kotlin
android {
    // ... existing configuration
    
    dependencies {
        // Neptune SDK dependencies
        implementation files('libs/neptune-sdk-4.15.00.aar') // Replace with actual filename
        implementation 'androidx.legacy:legacy-support-v4:1.0.0'
        implementation 'org.apache.httpcomponents:httpcore:4.4.10'
        implementation 'org.apache.httpcomponents:httpmime:4.5.6'
        implementation 'androidx.lifecycle:lifecycle-runtime-ktx:2.6.2'
        implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-android:1.6.4'
    }
}
```

#### Step 3: Add Permissions

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.NFC" />
<uses-permission android:name="android.permission.USB_PERMISSION" />
```

### 2. Implement Native Neptune Integration

#### Step 1: Update NeptuneCardHandler.kt

Replace the mock implementations in `NeptuneCardHandler.kt` with actual Neptune SDK calls:

```kotlin
// Add proper imports based on your Neptune SDK
import com.neptune.sdk.NeptuneManager
import com.neptune.sdk.CardReader
import com.neptune.sdk.Card
// ... other Neptune SDK imports

class NeptuneCardHandler(private val context: Context) {
    private var neptuneManager: NeptuneManager? = null
    private var cardReader: CardReader? = null
    
    fun initializeSDK(): Boolean {
        return try {
            neptuneManager = NeptuneManager.getInstance(context)
            cardReader = neptuneManager?.cardReader
            true
        } catch (e: Exception) {
            println("Error initializing Neptune SDK: ${e.message}")
            false
        }
    }

    fun readCardUID(): String? {
        return try {
            cardReader?.let { reader ->
                var cardUid: String? = null
                val latch = CountDownLatch(1)
                
                reader.detectCard(object : CardReader.CardDetectListener {
                    override fun onCardDetected(card: Card) {
                        cardUid = card.uid
                        latch.countDown()
                    }

                    override fun onError(error: Int) {
                        latch.countDown()
                    }
                })
                
                // Wait for detection with timeout
                if (latch.await(10, TimeUnit.SECONDS)) {
                    return cardUid
                } else {
                    return null
                }
            }
        } catch (e: Exception) {
            println("Error reading card UID: ${e.message}")
            null
        }
    }
    
    // Implement other methods similarly...
}
```

### 3. Backend API Setup

#### Step 1: Configure API Endpoints

Update `CardTransactionService` with your actual backend URLs:

```dart
class CardTransactionService {
  static const String baseUrl = 'https://your-backend-api.com/api';
  
  // Update with your actual API token
  static String get authToken => 'Bearer YOUR_ACTUAL_API_TOKEN';
  
  // ... rest of implementation
}
```

#### Step 2: Backend API Endpoints

Implement the following endpoints on your backend:

```bash
POST /api/card/process-payment
GET  /api/card/balance/{cardUid}
POST /api/card/add-funds
GET  /api/card/transactions/{cardUid}
GET  /api/card/verify/{cardUid}
POST /api/card/register
POST /api/card/deactivate
```

#### Sample Backend Response Formats:

**Payment Processing Response:**
```json
{
  "success": true,
  "transaction": {
    "cardUid": "A1B2C3D4",
    "amount": 150.00,
    "transactionId": "TXN_1234567890",
    "timestamp": 1642678800000,
    "status": "success",
    "merchantId": "MERCHANT_123",
    "metadata": {}
  }
}
```

**Card Balance Response:**
```json
{
  "success": true,
  "balance": {
    "cardUid": "A1B2C3D4", 
    "balance": 500.75,
    "lastUpdated": 1642678800000,
    "currency": "INR"
  }
}
```

### 4. Flutter Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  dio: ^5.4.0
  shared_preferences: ^2.2.2
  # ... other dependencies
```

## Usage Guide

### 1. Basic Card Reading

```dart
// Initialize Neptune SDK
final success = await NeptuneService.initializeSDK();

// Read single card
final cardUID = await NeptuneService.readCardUID();

// Start continuous detection
await NeptuneService.startCardDetection();

// Set up listener for card detection
NeptuneService.setCardDetectionListener(
  (String uid) {
    print('Card detected: $uid');
    // Process card
  },
  (String error) {
    print('Error: $error');
  },
);
```

### 2. Payment Processing

```dart
// Process payment with detected card
final transaction = await CardTransactionService.processPayment(
  cardUid: detectedCardUID,
  amount: 100.0,
  merchantId: 'MERCHANT_123',
  terminalId: 'TERMINAL_456',
);

if (transaction != null) {
  print('Payment successful: ${transaction.transactionId}');
} else {
  print('Payment failed');
}
```

### 3. Card Balance Management

```dart
// Get card balance
final balance = await CardTransactionService.getCardBalance(cardUID);

// Add funds to card
final success = await CardTransactionService.addFunds(
  cardUid: cardUID,
  amount: 200.0,
  paymentMethod: 'cash',
);
```

## Screen Integration

### NeptuneCardPaymentScreen Features

1. **SDK Initialization** - Automatic Neptune SDK setup
2. **Card Detection** - Continuous and single-read modes
3. **Balance Display** - Real-time card balance information
4. **Payment Processing** - Complete transaction workflow
5. **Funds Management** - Add funds to cards
6. **Error Handling** - Comprehensive error management

### Navigation

Access the Neptune card payment screen from:
- Dashboard → "Card Reader" option
- Direct route: `/neptune_card_payment`

## Testing

### 1. Mock Mode Testing

The current implementation includes mock responses for testing without actual hardware:

```kotlin
// Mock card UID generation
"MOCK_CARD_UID_${System.currentTimeMillis()}"

// Mock detection events every 3 seconds
// Mock successful operations
```

### 2. Hardware Testing

Once Neptune SDK is properly integrated:

1. Connect Neptune card reader device
2. Initialize SDK through the app
3. Test card detection with physical cards
4. Verify payment processing with backend
5. Test balance queries and fund additions

## Error Handling

### Common Error Scenarios

1. **SDK Initialization Failed**
   - Check Neptune device connection
   - Verify SDK library integration
   - Check permissions

2. **Card Detection Issues**
   - Ensure proper card placement
   - Check device connectivity
   - Verify SDK initialization

3. **Payment Processing Errors**
   - Check backend API connectivity
   - Verify card balance
   - Validate transaction data

4. **Backend API Issues**
   - Check network connectivity
   - Verify API endpoints
   - Validate authentication tokens

### Debug Logging

Enable detailed logging for troubleshooting:

```dart
// Flutter debug logs
print('Neptune operation: $details');

// Kotlin debug logs
println("Neptune SDK operation: $details")
```

## Production Deployment

### Security Considerations

1. **API Security**
   - Use HTTPS for all backend communications
   - Implement proper authentication tokens
   - Validate all transaction data

2. **Card Data Protection**
   - Never store sensitive card data locally
   - Use secure communication channels
   - Implement proper access controls

3. **Device Security**
   - Secure Neptune device connections
   - Implement proper session management
   - Use encrypted data transmission

### Performance Optimization

1. **Memory Management**
   - Properly dispose of card detection listeners
   - Clean up SDK resources on app termination
   - Handle background/foreground transitions

2. **Network Optimization**
   - Implement request timeouts
   - Use connection pooling for API calls
   - Cache non-sensitive data appropriately

3. **UI Responsiveness**
   - Use asynchronous operations
   - Show loading indicators
   - Provide user feedback

## Troubleshooting

### Common Issues and Solutions

1. **Neptune SDK Not Found**
   ```
   Error: Neptune classes not found
   Solution: Verify AAR file is in android/app/libs/ and dependencies are added
   ```

2. **Method Channel Communication Failed**
   ```
   Error: PlatformException
   Solution: Check method channel names match between Flutter and Android
   ```

3. **Card Detection Not Working**
   ```
   Error: No card detected
   Solution: Check device connection and permissions
   ```

4. **Payment Processing Failed**
   ```
   Error: Backend API error
   Solution: Verify API endpoints and authentication
   ```

### Support Resources

- Neptune SDK Documentation
- Flutter Method Channel Guide
- Backend API Integration Guide
- Hardware Setup Manual

## Conclusion

This Neptune card reader integration provides a complete solution for:
- Hardware card reading capabilities
- Real-time payment processing
- Backend transaction management
- User-friendly interface

The implementation is designed to be modular, secure, and production-ready while maintaining excellent user experience and comprehensive error handling.
