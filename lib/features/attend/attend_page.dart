import 'package:flutter/material.dart';
import '../../common/utils/constants.dart';

class AttendVisitPage extends StatelessWidget {
  const AttendVisitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '¡Alguien está en la puerta!',
              style: TextStyle(
                fontFamily: AppFonts.headline,
                fontSize: 28,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            // Placeholder for Video Stream
            Container(
              width: 300,
              height: 400,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.videocam_off, size: 100, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(Icons.close, 'Rechazar', Colors.red),
                _buildActionButton(Icons.notifications_off, 'Ignorar', Colors.grey),
                _buildActionButton(Icons.check, 'Aprobar', Colors.green),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontFamily: AppFonts.label)),
      ],
    );
  }
}
