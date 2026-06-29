import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'dashboard_screen.dart';
import 'analytics_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'add_transaction_sheet.dart';
import 'profile_screen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const AnalyticsScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _showAddTransactionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTransactionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userEmail = authProvider.currentUserEmail ?? 'User';
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedColor = isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.4);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.account_balance_wallet,
                color: primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'FinTrack',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: primaryColor.withValues(alpha: 0.15),
              child: Text(
                userEmail.isNotEmpty ? userEmail[0].toUpperCase() : '?',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionSheet(context),
        backgroundColor: primaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.dashboard,
                      color: _currentIndex == 0 ? primaryColor : unselectedColor,
                      size: 26,
                    ),
                    onPressed: () => _onTabTapped(0),
                    tooltip: 'Dashboard',
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    icon: Icon(
                      Icons.pie_chart,
                      color: _currentIndex == 1 ? primaryColor : unselectedColor,
                      size: 26,
                    ),
                    onPressed: () => _onTabTapped(1),
                    tooltip: 'Analytics',
                  ),
                ],
              ),
              const SizedBox(width: 48), // Notch spacing
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.history,
                      color: _currentIndex == 2 ? primaryColor : unselectedColor,
                      size: 26,
                    ),
                    onPressed: () => _onTabTapped(2),
                    tooltip: 'History',
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    icon: Icon(
                      Icons.settings,
                      color: _currentIndex == 3 ? primaryColor : unselectedColor,
                      size: 26,
                    ),
                    onPressed: () => _onTabTapped(3),
                    tooltip: 'Settings',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
