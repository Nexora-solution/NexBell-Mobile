import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';
import '../widgets/door_lock_panel.dart';
import '../widgets/pre_authorize_button.dart';
import '../widgets/today_visits_section.dart';
import '../widgets/recent_history_section.dart';

class DashboardPage extends StatelessWidget {
  final VoidCallback onPreAuthorize;
  final VoidCallback onSeeAllVisits;

  const DashboardPage({
    super.key,
    required this.onPreAuthorize,
    required this.onSeeAllVisits,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const DoorLockPanel(),
            const SizedBox(height: 24),
            PreAuthorizeButton(onTap: onPreAuthorize),
            const SizedBox(height: 32),
            TodayVisitsSection(onSeeAll: onSeeAllVisits),
            const SizedBox(height: 32),
            const RecentHistorySection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
