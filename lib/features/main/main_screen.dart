import 'package:flutter/material.dart';
import '../../common/utils/constants.dart';
import '../../common/widgets/top_bar.dart';
import '../dashboard/presentation/pages/dashboard_page.dart';
import '../access/presentation/pages/access_page.dart';
import '../activity/presentation/pages/activity_page.dart';
import '../settings/presentation/pages/settings_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDashboard = _selectedIndex == 0;
    bool isSettings = _selectedIndex == 3;

    final List<Widget> pages = [
      DashboardPage(
        onPreAuthorize: () => _onItemTapped(1),
        onSeeAllVisits: () => _onItemTapped(2),
      ),
      const AccessPage(),
      const ActivityPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: NexBellTopBar(
        isDashboard: isDashboard,
        isSettings: isSettings,
        onLogoTap: () => _onItemTapped(0),
        onProfileTap: () => _onItemTapped(3),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.neutral,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.grid_view_rounded, 'Dashboard'),
                _buildNavItem(1, Icons.person_add_alt_1_rounded, 'Access'),
                _buildNavItem(2, Icons.history_rounded, 'Activity'),
                _buildNavItem(3, Icons.settings_rounded, 'Settings'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey,
            ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontFamily: AppFonts.label,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
