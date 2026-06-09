import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';

class RecentHistorySection extends StatelessWidget {
  const RecentHistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent History",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: AppFonts.headline,
          ),
        ),
        const SizedBox(height: 16),
        _buildHistoryItem(
          Icons.door_front_door_outlined,
          'Visit Entry: Laura G.',
          '15 minutes ago • Access via QR',
        ),
        const SizedBox(height: 12),
        _buildHistoryItem(
          Icons.lock_open_outlined,
          'Lock Unlocked',
          'Today, 09:12 AM • User: Resident',
        ),
      ],
    );
  }

  Widget _buildHistoryItem(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFonts.body,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontFamily: AppFonts.label,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
