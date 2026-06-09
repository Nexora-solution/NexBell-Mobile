import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';

class PreAuthorizeButton extends StatelessWidget {
  final VoidCallback onTap;

  const PreAuthorizeButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.neutral,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add_alt_1_outlined, size: 24),
            SizedBox(width: 12),
            Text(
              'Pre-authorize Visit',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
