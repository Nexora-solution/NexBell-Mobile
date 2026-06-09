import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';
import '../pages/visit_detail_page.dart';

enum VisitStatus { approved, rejected, missed }

class ActivityItemCard extends StatelessWidget {
  final String visitorName;
  final String category;
  final String time;
  final VisitStatus status;
  final String? imageUrl;

  const ActivityItemCard({
    super.key,
    required this.visitorName,
    required this.category,
    required this.time,
    required this.status,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VisitDetailPage(
              visitorName: visitorName,
              category: category,
              time: time,
              status: status,
              imageUrl: imageUrl,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[800],
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
              child: imageUrl == null ? const Icon(Icons.person, color: Colors.white54) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    visitorName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFonts.body,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildStatusIndicator(),
                      const SizedBox(width: 8),
                      Text(
                        '•  $category',
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case VisitStatus.approved:
        color = AppColors.primary;
        label = 'Approved';
        icon = Icons.check_circle_outline;
        break;
      case VisitStatus.rejected:
        color = Colors.redAccent;
        label = 'Rejected';
        icon = Icons.cancel_outlined;
        break;
      case VisitStatus.missed:
        color = Colors.orangeAccent;
        label = 'Not attended';
        icon = Icons.error_outline;
        break;
    }

    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
