import 'package:cirmle_rfid_pos/screens/auth/signup_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/auth/signin_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/cards/issue_new_card_screen.dart';
import 'screens/cards/tap_new_card_screen.dart';
import 'screens/payments/payment_method_screen.dart';
import 'screens/payments/card_payment_screen.dart';
import 'screens/payments/upi_payment_screen.dart';
import 'screens/payments/transaction_failed_screen.dart';
import 'screens/cards/top_up_screen.dart';
import 'screens/cards/tap_card_screen.dart';
import 'screens/payments/topup_payment_method_screen.dart';
import 'screens/payments/topup_card_payment_screen.dart';
import 'screens/cards/check_balance_tap_card.dart';
import 'screens/cards/check_balance_amount_left.dart';
import 'screens/orders/order_screen.dart';
import 'screens/orders/order_summary_screen.dart';
import 'screens/payments/payment_success_screen.dart';
import 'screens/orders/bill_kot_screen.dart';
import 'screens/razorpay_pos/razorpay_pos_screen.dart';
import 'screens/razorpay_pos/pos_payment_screen.dart';
import 'screens/razorpay_pos/dqr_payment_screen.dart';
import 'screens/razorpay_pos/razorpay_pos_setup_screen.dart';
import 'screens/payments/razorpay_pos_main_screen.dart';
import 'screens/cards/neptune_card_payment_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cirkle POS',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => SignInPage(),
        '/signup': (context) => SignUpPage(),
        '/dashboard': (context) => DashboardScreen(),
        '/issue_new_card': (context) => IssueNewCardScreen(),
        '/tap_card': (context) => TapCardScreen(),
        '/tap_new_card': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return TapNewCardScreen(
            cardData: args?['cardData'] ?? {},
            paymentMethod: args?['paymentMethod'] ?? 'Unknown',
          );
        },
        '/top_up': (context) => TopUpScreen(),
        '/topup': (context) => TopUpScreen(),
        '/topup_tap_card': (context) => TapCardScreen(),
        '/check_balance_tap_card': (context) => CheckBalanceTapCardScreen(),
        '/check_balance_amount_left': (context) => CheckBalanceAmountLeftScreen(),
        '/order': (context) => OrderScreen(),
        '/order_summary': (context) => OrderSummaryScreen(),
        '/payment_bill': (context) => TransactionFailedScreen(),
        '/bill_kot': (context) => BillKotScreen(),
        '/card_payment': (context) => CardPaymentScreen(),
        '/topup_card_payment': (context) => TopupCardPaymentScreen(),
        '/payment_method': (context) => PaymentMethodScreen(),
        '/topup_payment_method': (context) => TopupPaymentMethodScreen(),
        '/payment_success': (context) => PaymentSuccessScreen(),
        '/upi_payment': (context) => UpiPaymentScreen(),
        '/transaction_failed': (context) => TransactionFailedScreen(),
        '/razorpay_pos': (context) => const RazorpayPOSScreen(),
        '/razorpay_pos_main': (context) => const RazorpayPOSMainScreen(),
        '/neptune_card_payment': (context) => const NeptuneCardPaymentScreen(),
        '/pos_payment': (context) => const POSPaymentScreen(),
        '/dqr_payment': (context) => const DQRPaymentScreen(),
        '/razorpay_pos_setup': (context) => const RazorpayPOSSetupScreen(),
      },
    );
  }
}