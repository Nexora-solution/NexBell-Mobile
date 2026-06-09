// lib/features/activity/presentation/widgets/activity_section_header.dart
import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';

class ActivitySectionHeader extends StatelessWidget {
  final String title;

  const ActivitySectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontFamily: AppFonts.label,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(child: Divider(color: Colors.white10)),
        ],
      ),
    );
  }
}