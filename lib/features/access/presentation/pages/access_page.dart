import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';
import '../widgets/access_toggles.dart';
import '../widgets/visitor_form.dart';

class AccessPage extends StatelessWidget {
  const AccessPage({super.key});

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
                'Visitor Access',
                style: TextStyle(
                  fontFamily: AppFonts.headline,
                  fontSize: 32,
                  color: Colors.white,
                ),
              ),
            ),
            const Text(
              'Configure a pre-authorization to speed up entry to the residence.',
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            const VisitorForm(),
            const SizedBox(height: 16),
            const AccessToggles(),
            const SizedBox(height: 24),
            // Info Message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'The doorman will receive this information automatically to speed up entry.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        fontFamily: AppFonts.body,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement pre-authorization generation
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.neutral,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Generate Pre-authorization',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppFonts.body,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.shield_outlined, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
