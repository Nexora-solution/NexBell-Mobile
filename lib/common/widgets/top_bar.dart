import 'package:flutter/material.dart';
import '../utils/constants.dart';

class NexBellTopBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDashboard;
  final bool isSettings;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLogoTap;

  const NexBellTopBar({
    super.key,
    this.isDashboard = false,
    this.isSettings = false,
    this.onProfileTap,
    this.onLogoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 8),
      color: AppColors.background,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo and Name
          GestureDetector(
            onTap: isDashboard ? null : onLogoTap,
            child: Opacity(
              opacity: isDashboard ? 0.5 : 1.0,
              child: Row(
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'NEXBELL',
                    style: TextStyle(
                      fontFamily: AppFonts.headline,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Profile Avatar
          GestureDetector(
            onTap: isSettings ? null : onProfileTap,
            child: Opacity(
              opacity: isSettings ? 0.5 : 1.0,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                child: const Text(
                  'JD',
                  style: TextStyle(
                    color: AppColors.neutral,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
