import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/pending_notification_store.dart';
import '../utils/constants.dart';

class NexBellTopBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDashboard;
  final bool isSettings;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLogoTap;
  final VoidCallback? onNotificationsTap;
  final String? initials;
  final Uint8List? photoBytes;

  const NexBellTopBar({
    super.key,
    this.isDashboard = false,
    this.isSettings = false,
    this.onProfileTap,
    this.onLogoTap,
    this.onNotificationsTap,
    this.initials,
    this.photoBytes,
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
                    'Nexora',
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
          Row(
            children: [
              ValueListenableBuilder<PendingVisitNotification?>(
                valueListenable: PendingNotificationStore.current,
                builder: (context, pending, _) {
                  return GestureDetector(
                    onTap: onNotificationsTap,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.notifications_none_rounded,
                            color: AppColors.primary,
                            size: 26,
                          ),
                        ),
                        if (pending != null)
                          Positioned(
                            right: 2,
                            top: 2,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE57373),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.background, width: 1.5),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 14),
              // Profile Avatar
              GestureDetector(
                onTap: isSettings ? null : onProfileTap,
                child: Opacity(
                  opacity: isSettings ? 0.5 : 1.0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary,
                    backgroundImage: photoBytes != null ? MemoryImage(photoBytes!) : null,
                    child: photoBytes == null
                        ? Text(
                            (initials == null || initials!.isEmpty) ? '?' : initials!,
                            style: const TextStyle(
                              color: AppColors.neutral,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: AppFonts.headline,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
