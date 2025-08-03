# Cirkle POS Application

## Authentication Flow with AWS Cognito

### Overview

This application uses AWS Cognito for authentication and user management. The implementation follows these key steps:

1. User enters credentials in the login screen
2. AWS Cognito authentication is performed via the `amazon_cognito_identity_dart_2` package
3. Upon successful login, JWT tokens are securely stored
4. API calls use these tokens for authentication

### Authentication Components

#### CognitoService

The `CognitoService` handles direct interaction with AWS Cognito:

- User pool configuration (pool ID: `ap-south-1_QntFxqDq4`)
- Authentication with username/password
- Token management and refresh
- User attribute parsing

#### AuthService

The `AuthService` provides a simplified interface for the application:

- Wraps CognitoService functionality
- Manages tokens and user state
- Provides API call utility with authentication
- Handles user roles and permissions

### API Integration

All authenticated API calls use the base URL:
```
https://kiis0e7lfj.execute-api.ap-south-1.amazonaws.com/uat
```

### Neptune Card Reader Integration

The application integrates with Neptune card readers for RFID card operations:

- Card detection and UID reading
- Payment processing via cards
- Card balance management
- Transaction history

#### Testing Without Hardware

A mock implementation is available for testing without physical Neptune hardware:
- Enable mock mode: `NeptuneService().useMockImplementation = true`
- This simulates card detection events and responses

### Secure Data Storage

Sensitive data is stored using `flutter_secure_storage`:
- Access tokens
- Refresh tokens
- User session data

### API Services

The application includes these key services:

1. **AuthService**: Authentication and token management
2. **CardTransactionService**: Card payments and balance
3. **NeptuneService**: Card reader hardware integration
4. **MockNeptuneService**: Testing implementation

### Application Flow

1. User authenticates via AWS Cognito
2. Based on role, user is directed to appropriate dashboard:
   - Admin Dashboard
   - Topup Dashboard
   - Stall Vendor Dashboard
3. From the dashboard, users can:
   - Process payments with Neptune card reader
   - Issue new cards
   - Check balance
   - Process orders
   - Manage transactions
