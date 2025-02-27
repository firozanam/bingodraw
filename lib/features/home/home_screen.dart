import 'package:flutter/material.dart';
import '../lottery/screens/lottery_screen.dart';
import '../lottery/screens/my_tickets_screen.dart';
import '../admin/screens/admin_dashboard_screen.dart';
import '../wallet/screens/transaction_history_screen.dart';
import '../auth/auth_service.dart';
import '../../core/config/app_config.dart';
import '../wallet/widgets/wallet_status_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _authService = AuthService();

  final List<Widget> _screens = [
    const LotteryScreen(),
    const MyTicketsScreen(),
    const AdminDashboardScreen(),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.confirmation_number,
      label: 'Lottery',
      index: 0,
    ),
    NavigationItem(
      icon: Icons.receipt_long,
      label: 'My Tickets',
      index: 1,
    ),
    NavigationItem(
      icon: Icons.admin_panel_settings,
      label: 'Admin',
      index: 2,
    ),
  ];

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Lottery';
      case 1:
        return 'My Tickets';
      case 2:
        return 'Admin Dashboard';
      default:
        return 'Lottery';
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _authService.authStateChanges.map((user) => user != null),
      builder: (context, snapshot) {
        final isAuthenticated = snapshot.data ?? false;

        return Scaffold(
          appBar: AppBar(
            title: Text(_getAppBarTitle(_currentIndex)),
          ),
          drawer: isAuthenticated ? _buildDrawer(context) : null,
          body: isAuthenticated
              ? _screens[_currentIndex]
              : const Center(
                  child: Text('Please sign in to continue'),
                ),
          bottomNavigationBar: isAuthenticated
              ? NavigationBar(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  destinations: _navigationItems
                      .map((item) => NavigationDestination(
                            icon: Icon(item.icon),
                            label: item.label,
                          ))
                      .toList(),
                )
              : null,
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person),
            ),
            accountName: Text(_authService.currentUser?.email ?? ''),
            accountEmail: null,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: WalletStatusWidget(),
          ),
          const Divider(),
          ..._navigationItems.map(
            (item) => ListTile(
              leading: Icon(item.icon),
              title: Text(item.label),
              selected: _currentIndex == item.index,
              onTap: () {
                setState(() => _currentIndex = item.index);
                Navigator.pop(context);
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Transaction History'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransactionHistoryScreen(),
                ),
              );
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.pop(context);
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final int index;

  const NavigationItem({
    required this.icon,
    required this.label,
    required this.index,
  });
}