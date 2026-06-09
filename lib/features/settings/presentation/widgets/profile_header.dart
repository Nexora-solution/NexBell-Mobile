import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String tier;
  final String initials;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.tier,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[800],
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontFamily: AppFonts.headline,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit,
                  size: 20,
                  color: AppColors.neutral,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: const TextStyle(
            fontSize: 28,
            fontFamily: AppFonts.headline,
            color: Colors.white,
          ),
        ),
        Text(
          tier,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontFamily: AppFonts.body,
          ),
        ),
      ],
    );
  }
}
