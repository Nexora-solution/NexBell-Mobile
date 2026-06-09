// lib/features/activity/presentation/pages/activity_page.dart
import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';
import '../widgets/activity_item_card.dart';
import '../widgets/activity_section_header.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 24.0, bottom: 8.0),
              child: Text(
                'Activity History',
                style: TextStyle(
                  fontFamily: AppFonts.headline,
                  fontSize: 32,
                  color: Colors.white,
                ),
              ),
            ),
            const ActivitySectionHeader(title: 'TODAY'),
            const ActivityItemCard(
              visitorName: 'Carlos Mendoza',
              category: 'Delivery',
              time: '14:30',
              status: VisitStatus.approved,
            ),
            const ActivityItemCard(
              visitorName: 'AC Maintenance',
              category: 'Technician',
              time: '09:15',
              status: VisitStatus.rejected,
            ),
            const ActivitySectionHeader(title: 'YESTERDAY'),
            const ActivityItemCard(
              visitorName: 'Elena Rodriguez',
              category: 'Personal',
              time: '18:45',
              status: VisitStatus.approved,
            ),
            const ActivityItemCard(
              visitorName: 'Unknown Visitor',
              category: 'Unknown',
              time: '11:20',
              status: VisitStatus.missed,
            ),
            const ActivitySectionHeader(title: 'THIS WEEK'),
            const ActivityItemCard(
              visitorName: 'Amazon Logistics',
              category: 'Delivery',
              time: 'Monday',
              status: VisitStatus.approved,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}