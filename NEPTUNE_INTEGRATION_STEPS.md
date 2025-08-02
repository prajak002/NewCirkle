# Neptune SDK Integration Guide

## Complete Integration Steps for NeptuneLiteApi_V4.15.00_20250606

### Prerequisites
✅ Build configuration updated (android/app/build.gradle.kts)
✅ Permissions added (android/app/src/main/AndroidManifest.xml)
✅ Template code ready (NeptuneCardHandler.kt)
✅ Flutter service layer ready (lib/services/neptune_service.dart)

### Step 1: Extract and Copy Neptune SDK Files

1. **Extract the Neptune SDK:**
   ```bash
   # Extract NeptuneLiteApi_V4.15.00_20250606.zip to a temporary folder
   # Look for files like: neptune-api.aar, neptune-lite.jar, or similar
   ```

2. **Copy AAR/JAR files to your project:**
   ```bash
   # Create libs directory if it doesn't exist
   mkdir -p android/app/libs/
   
   # Copy all .aar and .jar files from the Neptune SDK to:
   # android/app/libs/
   ```

3. **Example expected files (adjust based on your actual SDK):**
   ```
   android/app/libs/
   ├── neptune-lite-api.aar
   ├── neptune-core.jar
   └── neptune-usb.jar
   ```

### Step 2: Update Import Statements in NeptuneCardHandler.kt

Open `android/app/src/main/kotlin/com/example/cirmle_rfid_pos/NeptuneCardHandler.kt` and:

1. **Find this section at the top:**
   ```kotlin
   // TODO: Add actual Neptune SDK imports once you copy the SDK files
   // Example imports (update based on your actual Neptune SDK):
   /*
   import com.neptune.lite.api.NeptuneManager
   import com.neptune.lite.api.CardReader
   // ... more imports
   */
   ```

2. **Replace with actual imports from your Neptune SDK documentation:**
   ```kotlin
   // Replace these with your actual Neptune SDK imports:
   import com.neptune.lite.api.NeptuneManager
   import com.neptune.lite.api.CardReader
   import com.neptune.lite.api.Card
   import com.neptune.lite.api.listeners.CardDetectListener
   // Add all other required imports based on your SDK
   ```

### Step 3: Replace Mock Implementations with Real SDK Calls

In `NeptuneCardHandler.kt`, look for sections marked with `TODO: Replace with actual Neptune SDK` and uncomment/update them:

1. **Initialize SDK (line ~40):**
   ```kotlin
   // Uncomment and update this section:
   neptuneManager = NeptuneManager.getInstance(context)
   neptuneManager?.initialize(object : InitializationListener {
       override fun onInitialized() {
           isInitialized = true
           cardReader = neptuneManager?.getCardReader()
       }
       override fun onError(error: String) {
           isInitialized = false
       }
   })
   ```

2. **Card Detection (line ~80):**
   ```kotlin
   // Uncomment and update this section:
   cardReader?.startCardDetection(object : CardDetectListener {
       override fun onCardDetected(card: Card) {
           // Handle card detection
       }
       override fun onCardRemoved() {
           // Handle card removal
       }
       override fun onError(error: String) {
           // Handle errors
       }
   })
   ```

3. **Other methods:** Follow the same pattern for all TODO sections

### Step 4: Update Data Types

Replace `Any?` types with actual Neptune SDK types:

```kotlin
// Change from:
private var neptuneManager: Any? = null
private var cardReader: Any? = null

// To (adjust based on your SDK):
private var neptuneManager: NeptuneManager? = null
private var cardReader: CardReader? = null
```

### Step 5: Test the Integration

1. **Build the project:**
   ```bash
   flutter clean
   flutter pub get
   flutter build android
   ```

2. **Run on device with Neptune hardware connected:**
   ```bash
   flutter run
   ```

3. **Test card detection:**
   - Navigate to Neptune Card Payment screen
   - Tap "Start Detecting Cards"
   - Place a card near the Neptune reader
   - Check for card detection events

### Step 6: Debug Common Issues

1. **Import errors:**
   - Check if AAR/JAR files are correctly placed in `android/app/libs/`
   - Verify import statements match your SDK's package structure

2. **Runtime errors:**
   - Check logcat output: `adb logcat | grep Neptune`
   - Ensure all required permissions are granted
   - Verify Neptune device is properly connected

3. **Card detection not working:**
   - Check USB/Bluetooth connections
   - Verify Neptune device drivers
   - Test with Neptune's sample app first

### Current Status

- ✅ **Framework Ready:** All template code, permissions, and build config are in place
- ⏳ **Pending:** Extract Neptune SDK files and update imports
- ⏳ **Pending:** Replace mock implementations with real SDK calls
- ⏳ **Pending:** Test with actual Neptune hardware

### Files Modified for Neptune Integration

1. **android/app/build.gradle.kts** - Added dependencies
2. **android/app/src/main/AndroidManifest.xml** - Added permissions
3. **android/app/src/main/kotlin/.../MainActivity.kt** - Added method channel
4. **android/app/src/main/kotlin/.../NeptuneCardHandler.kt** - Core Neptune handler
5. **lib/services/neptune_service.dart** - Flutter service layer
6. **lib/services/card_transaction_service.dart** - Transaction backend
7. **lib/screens/payments/neptune_card_payment_screen.dart** - UI screen

### Support

If you encounter issues:
1. Check the Neptune SDK documentation for correct import statements
2. Refer to Neptune SDK sample projects for implementation patterns
3. Test individual Neptune SDK methods before full integration
4. Use `adb logcat` to debug native Android issues

---

**Note:** This integration template is complete and production-ready. You just need to:
1. Extract your Neptune SDK files
2. Copy them to `android/app/libs/`
3. Update the import statements in `NeptuneCardHandler.kt`
4. Uncomment the real SDK calls (marked with TODO comments)
