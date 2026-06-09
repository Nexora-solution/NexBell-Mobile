import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';

class DoorLockPanel extends StatefulWidget {
  const DoorLockPanel({super.key});

  @override
  State<DoorLockPanel> createState() => _DoorLockPanelState();
}

class _DoorLockPanelState extends State<DoorLockPanel> {
  bool _isLocked = true;

  void _toggleLock() {
    setState(() {
      _isLocked = !_isLocked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleLock,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: _isLocked ? Colors.transparent : AppColors.primary.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isLocked ? Colors.white10 : AppColors.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                _isLocked ? Icons.lock_outline : Icons.lock_open_outlined,
                size: 48,
                color: _isLocked ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _isLocked ? 'Cerradura Asegurada' : 'Cerradura Desbloqueada',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.headline,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'PUERTA PRINCIPAL • ONLINE',
              style: TextStyle(
                color: _isLocked ? Colors.grey : AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                fontFamily: AppFonts.label,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
