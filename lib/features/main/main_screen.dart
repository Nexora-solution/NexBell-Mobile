import 'dart:convert';
import 'package:flutter/material.dart';
import '../../common/utils/constants.dart';
import '../../common/utils/api_client.dart';
import '../../common/widgets/top_bar.dart';
import '../dashboard/presentation/pages/dashboard_page.dart';
import '../access/presentation/pages/access_page.dart';
import '../activity/presentation/pages/activity_page.dart';
import '../settings/presentation/pages/settings_page.dart';
import '../intercom/presentation/pages/notifications_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

// Tab order matches the bottom nav in the mockup: Inicio, Actividad, Visitas, Perfil.
class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String? _initials;

  @override
  void initState() {
    super.initState();
    _fetchInitials();
  }

  Future<void> _fetchInitials() async {
    try {
      final res = await ApiClient.get('/api/iam/users/me');
      if (res.statusCode != 200) return;
      final data = jsonDecode(res.body);
      final name = (data['fullName'] as String? ?? '').trim();
      if (name.isEmpty) return;
      final parts = name.split(RegExp(r'\s+'));
      final initials = parts.length > 1
          ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
          : parts[0][0].toUpperCase();
      if (mounted) setState(() => _initials = initials);
    } catch (_) {
      // No photo upload support yet, so this just falls back to '?' in the
      // top bar — same behavior the web uses when there's no avatar on file.
    }
  }

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
        onPreAuthorize: () => _onItemTapped(2),
        onSeeAllVisits: () => _onItemTapped(1),
      ),
      const ActivityPage(),
      const AccessPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: NexBellTopBar(
        isDashboard: isDashboard,
        isSettings: isSettings,
        initials: _initials,
        onLogoTap: () => _onItemTapped(0),
        onProfileTap: () => _onItemTapped(3),
        onNotificationsTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationsPage()),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.primary,
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
                _buildNavItem(0, Icons.grid_view_rounded, 'Inicio'),
                _buildNavItem(1, Icons.history_rounded, 'Actividad'),
                _buildNavItem(2, Icons.person_add_alt_1_rounded, 'Visitas'),
                _buildNavItem(3, Icons.shield_rounded, 'Perfil'),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.neutral,
            ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.neutral,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.label,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
