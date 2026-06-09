import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';
import '../widgets/profile_header.dart';
import '../widgets/personal_info_section.dart';
import '../widgets/security_section.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data
    const String name = 'Julian Draxler';
    const String email = 'julian.draxler@vigilant.com';
    const String tier = 'Premium Security Tier';
    const String initials = 'JD';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            children: [
              const ProfileHeader(
                name: name,
                tier: tier,
                initials: initials,
              ),
              const SizedBox(height: 32),
              const PersonalInfoSection(
                initialName: name,
                initialEmail: email,
              ),
              const SizedBox(height: 24),
              const SecuritySection(),
              const SizedBox(height: 40),
              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement logout logic
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.red.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                        side: BorderSide(color: Colors.red.withOpacity(0.2)),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppFonts.body,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
