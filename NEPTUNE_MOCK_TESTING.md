# Neptune SDK Integration Testing Guide

## Mock Testing Without Physical Hardware

This guide explains how to use the Neptune mock test functionality to test your implementation without a physical card reader device.

### Accessing the Mock Test Interface

1. Launch the application
2. Sign in with your test credentials
3. From the Dashboard, tap on the "Neptune Test" button (orange icon)
4. You'll be taken to the Neptune Mock Testing screen

### Testing Workflow

#### Step 1: Initialize the SDK
- Tap "Initialize SDK" button
- The status will update to indicate successful initialization
- The "Reader Ready" indicator will turn green when initialized

#### Step 2: Detect a Card
- Tap "Detect Card" to simulate a card being presented to the reader
- After a short delay (simulating real hardware), a mock card UID will appear
- The card's simulated balance will also be displayed

#### Step 3: Process a Transaction
- Enter an amount in the amount field
- Enter test values for Merchant ID and Terminal ID
- Tap "Process Payment" to simulate a payment transaction
- The system will check if the card has sufficient balance
- After processing, a transaction receipt will be displayed

#### Step 4: Top-up Funds
- With a card detected, enter an amount in the amount field
- Tap "Add Funds" to simulate adding money to the card
- The updated balance will be displayed
- Transaction history will also be updated

### Mock Service Features

The mock service includes realistic behaviors to help with testing:

1. **Simulated delays** - Card detection and transactions have realistic timing
2. **Random failures** - Occasional failures occur to test error handling (5-10% of operations)
3. **Persistent balance** - Card balances remain consistent between operations
4. **Transaction history** - Mock service maintains transaction records
5. **Validation** - Proper validation of sufficient funds, input fields, etc.

### Switching Between Mock and Real Implementation

For developers: The `NeptuneService` class can be configured to use either the mock implementation or the real hardware implementation:

```dart
// Get the Neptune service instance
final neptuneService = NeptuneService();

// Check current mode
bool isMockMode = neptuneService.isMockMode;

// Switch to real hardware mode (when hardware is available)
neptuneService.useMockImplementation = false;
```

### Common Mock Testing Scenarios

1. **Insufficient funds testing**
   - Detect a card with a low balance
   - Attempt to process a payment larger than the available balance
   - Verify that the proper error message is displayed

2. **Transaction failure handling**
   - The mock service randomly simulates failures
   - Process multiple transactions to trigger a simulated failure
   - Verify that the UI properly handles and displays the error

3. **Top-up flow testing**
   - Detect a card and note its initial balance
   - Add funds to the card
   - Verify that the balance increases by the correct amount
   - Check that the transaction history is updated

4. **Multiple card detection**
   - Tap "Detect Card" multiple times to simulate different cards
   - Verify that each card has its own balance and history

## Moving to Real Hardware

When you're ready to test with physical Neptune hardware:

1. Make sure the Neptune SDK is properly installed
2. Connect your Neptune card reader device
3. Use the main application flow rather than the test screen
4. The same code will work with real hardware since the interfaces are identical

The mock testing functionality ensures that your application logic works correctly before connecting to physical hardware, saving development time and enabling testing without specialized equipment.
