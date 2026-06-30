import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';
import '../../../../common/utils/image_utils.dart';
import '../pages/visit_detail_page.dart';

enum VisitStatus { approved, rejected, missed }

class ActivityItemCard extends StatelessWidget {
  final String visitorName;
  final String time;
  final VisitStatus status;
  final String? photoUrl;
  final String document;
  final DateTime? scheduledAt;

  const ActivityItemCard({
    super.key,
    required this.visitorName,
    required this.time,
    required this.status,
    this.photoUrl,
    this.document = '',
    this.scheduledAt,
  });

  @override
  Widget build(BuildContext context) {
    final image = avatarImageProvider(photoUrl);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VisitDetailPage(
              visitorName: visitorName,
              status: status,
              photoUrl: photoUrl,
              document: document,
              scheduledAt: scheduledAt,
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
              backgroundColor: AppColors.primary.withOpacity(0.18),
              backgroundImage: image,
              child: image == null
                  ? Text(
                      visitorName.trim().isEmpty ? '?' : visitorName.trim()[0].toUpperCase(),
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    )
                  : null,
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
                  _buildStatusIndicator(),
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
        label = 'Aprobado';
        icon = Icons.check_circle_outline;
        break;
      case VisitStatus.rejected:
        color = Colors.redAccent;
        label = 'Rechazado';
        icon = Icons.cancel_outlined;
        break;
      case VisitStatus.missed:
        color = Colors.orangeAccent;
        label = 'No atendido';
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
