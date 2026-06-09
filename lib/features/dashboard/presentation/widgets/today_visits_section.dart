import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';

class TodayVisitsSection extends StatelessWidget {
  final VoidCallback onSeeAll;

  const TodayVisitsSection({super.key, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Today's Visits",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.headline,
              ),
            ),
            TextButton(
              onPressed: onSeeAll,
              child: const Text(
                'See All',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.label,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildVisitPill(Icons.delivery_dining_outlined, 'Rappi', '14:30'),
              const SizedBox(width: 12),
              _buildVisitPill(Icons.person_outline, 'Laura G.', '18:00'),
              const SizedBox(width: 12),
              _buildVisitPill(Icons.home_repair_service_outlined, 'Technician', '10:00'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVisitPill(IconData icon, String name, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: AppFonts.body,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            '•',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: const TextStyle(
              color: Colors.grey,
              fontFamily: AppFonts.label,
            ),
          ),
        ],
      ),
    );
  }
}
