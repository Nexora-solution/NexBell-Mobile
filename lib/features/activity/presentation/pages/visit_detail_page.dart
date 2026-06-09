import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';
import '../widgets/activity_item_card.dart';

class VisitDetailPage extends StatelessWidget {
  final String visitorName;
  final String category;
  final String time;
  final VisitStatus status;
  final String? imageUrl;

  const VisitDetailPage({
    super.key,
    required this.visitorName,
    required this.category,
    required this.time,
    required this.status,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Visit Detail',
          style: TextStyle(
            color: Colors.white,
            fontFamily: AppFonts.headline,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[800],
                backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
                child: imageUrl == null ? const Icon(Icons.person, size: 60, color: Colors.white54) : null,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              visitorName,
              style: const TextStyle(
                fontSize: 28,
                fontFamily: AppFonts.headline,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            _buildStatusBadge(),
            const SizedBox(height: 32),
            _buildDetailRow(Icons.category_outlined, 'Category', category),
            _buildDetailRow(Icons.access_time_rounded, 'Time', time),
            _buildDetailRow(Icons.calendar_today_rounded, 'Date', 'October 24, 2023'), // Mock date
            const SizedBox(height: 32),
            const Divider(color: Colors.white10),
            const SizedBox(height: 32),
            _buildAdditionalInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String label;
    switch (status) {
      case VisitStatus.approved:
        color = AppColors.primary;
        label = 'Approved';
        break;
      case VisitStatus.rejected:
        color = Colors.redAccent;
        label = 'Rejected';
        break;
      case VisitStatus.missed:
        color = Colors.orangeAccent;
        label = 'Not attended';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Information',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: AppFonts.headline,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Visitor arrived at the main gate and requested access to Apartment 402. The resident was notified via the mobile app and approved the visit.',
          style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
        ),
      ],
    );
  }
}
