
import 'package:flutter/material.dart';
import '../cards/issue_new_card_screen.dart';
import '../cards/top_up_screen.dart';

class DashboardScreen extends StatelessWidget {
  final List<_DashboardItem> items = [
    _DashboardItem(
      icon: Icons.credit_card,
      label: "Issue New Card",
      route: '/issue_new_card',
    ),
    _DashboardItem(icon: Icons.account_balance_wallet, label: "Top Up", route: '/topup'),
    _DashboardItem(
      icon: Icons.account_balance,
      label: "Check Balance",
      route: '/check_balance_tap_card',
    ),
    _DashboardItem(icon: Icons.shopping_cart, label: "Order", route: '/order'),
    _DashboardItem(icon: Icons.money_off, label: "Refund", route: '/refund'),
    _DashboardItem(
      icon: Icons.analytics,
      label: "Summary",
      route: '/summary',
    ),
    _DashboardItem(
      icon: Icons.contactless,
      label: "Card Reader",
      route: '/card_payment',
    ),
    _DashboardItem(
      icon: Icons.bug_report,
      label: "Neptune Test",
      route: '/neptune_mock_test',
      color: Colors.orange,
    ),
  ];

  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final height = screenSize.height;
    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1200;

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced Header with better responsiveness
            Container(
              height: isMobile ? 120 : (isTablet ? 140 : 160),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : 32,
                  vertical: isMobile ? 16 : 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Cirkle",
                      style: TextStyle(
                        fontSize: isMobile ? 32 : (isTablet ? 36 : 40),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "An ecosystem for events",
                      style: TextStyle(
                        fontSize: isMobile ? 14 : (isTablet ? 16 : 18),
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Improved Grid Section
            Expanded(
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.all(isMobile ? 16 : 24),
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dashboard",
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Choose an option to get started",
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: GridView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: items.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isMobile ? 2 : (isTablet ? 3 : 4),
                          mainAxisSpacing: isMobile ? 16 : 20,
                          crossAxisSpacing: isMobile ? 16 : 20,
                          childAspectRatio: isMobile ? 1.0 : 1.1,
                        ),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _DashboardButton(
                            icon: item.icon,
                            label: item.label,
                            onTap: () {
                              Navigator.pushNamed(context, item.route);
                            },
                            isMobile: isMobile,
                            isTablet: isTablet,
                            iconColor: item.color,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced Button Widget with better responsiveness
class _DashboardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isMobile;
  final bool isTablet;
  final Color? iconColor;

  const _DashboardButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isMobile = false,
    this.isTablet = false,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Color(0xFF1976D2).withOpacity(0.1), width: 1),
            gradient: LinearGradient(
              colors: [
                Color(0xFF1976D2).withOpacity(0.05),
                Color(0xFF42A5F5).withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                decoration: BoxDecoration(
                  color: Color(0xFF1976D2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: isMobile ? 32 : (isTablet ? 36 : 40),
                  color: iconColor ?? Color(0xFF1976D2),
                ),
              ),
              SizedBox(height: isMobile ? 8 : 12),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 12 : (isTablet ? 14 : 16),
                    color: iconColor ?? Color(0xFF1976D2),
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Dashboard menu item data model
class _DashboardItem {
  final IconData icon;
  final String label;
  final String route;
  final Color? color;
  
  _DashboardItem({
    required this.icon,
    required this.label,
    required this.route,
    this.color,
  });
}
