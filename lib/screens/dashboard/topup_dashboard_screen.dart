import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class TopUpDashboardScreen extends StatefulWidget {
  const TopUpDashboardScreen({super.key});

  @override
  State<TopUpDashboardScreen> createState() => _TopUpDashboardScreenState();
}

class _TopUpDashboardScreenState extends State<TopUpDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Top-Up Counter'),
        backgroundColor: Color(0xFF1976D2),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Top-Up', icon: Icon(Icons.account_balance_wallet)),
            Tab(text: 'Check Balance', icon: Icon(Icons.credit_card)),
            Tab(text: 'Transactions', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Top-Up Tab Content
          _buildTopUpTab(),
          
          // Check Balance Tab Content
          _buildCheckBalanceTab(),
          
          // Transactions Tab Content
          _buildTransactionsTab(),
        ],
      ),
    );
  }

  Widget _buildTopUpTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Card Top-Up',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Add funds to customer cards using payment options.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/topup');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1976D2),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: Icon(Icons.add),
                    label: Text('New Top-Up'),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          Text(
            'Recent Top-Ups',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          
          // Mock recent top-ups list
          Expanded(
            child: ListView(
              children: List.generate(5, (index) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(0xFF1976D2).withOpacity(0.2),
                      child: Icon(Icons.credit_card, color: Color(0xFF1976D2)),
                    ),
                    title: Text('Card ${12345 + index}'),
                    subtitle: Text('${DateTime.now().subtract(Duration(hours: index)).toString().substring(0, 16)}'),
                    trailing: Text(
                      '₹${(index + 1) * 100}.00',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckBalanceTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card,
            size: 64,
            color: Color(0xFF1976D2),
          ),
          SizedBox(height: 24),
          Text(
            'Check Card Balance',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976D2),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Tap a card to check its current balance',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/check_balance_tap_card');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1976D2),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(Icons.contactless),
            label: Text('Tap Card'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction History',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976D2),
            ),
          ),
          SizedBox(height: 16),
          
          // Filter options
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: Color(0xFF1976D2)),
                  ),
                  child: Text('Today'),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: Color(0xFF1976D2)),
                  ),
                  child: Text('This Week'),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: Color(0xFF1976D2)),
                  ),
                  child: Text('All Time'),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          // Transactions list
          Expanded(
            child: ListView.builder(
              itemCount: 15,
              itemBuilder: (context, index) {
                final isTopUp = index % 2 == 0;
                
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isTopUp 
                          ? Colors.green.withOpacity(0.2) 
                          : Colors.orange.withOpacity(0.2),
                      child: Icon(
                        isTopUp ? Icons.add : Icons.shopping_cart,
                        color: isTopUp ? Colors.green : Colors.orange,
                      ),
                    ),
                    title: Text(
                      isTopUp ? 'Top-Up Transaction' : 'Purchase',
                    ),
                    subtitle: Text(
                      '${DateTime.now().subtract(Duration(days: index)).toString().substring(0, 16)}'
                    ),
                    trailing: Text(
                      isTopUp ? '+₹${(index + 1) * 100}.00' : '-₹${(index + 1) * 25}.00',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isTopUp ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
