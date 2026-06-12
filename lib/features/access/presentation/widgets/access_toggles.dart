import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';

class AccessToggles extends StatefulWidget {
  const AccessToggles({super.key});

  @override
  State<AccessToggles> createState() => _AccessTogglesState();
}

class _AccessTogglesState extends State<AccessToggles> {
  bool _isRecurring = false;
  bool _notifyOnArrival = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildToggle(
            'Recurring Visit',
            'WEEKLY AUTHORIZATION',
            _isRecurring,
            (val) => setState(() => _isRecurring = val),
          ),
          const Divider(color: Colors.white10, indent: 20, endIndent: 20),
          _buildToggle(
            'Notify on Arrival',
            'REAL-TIME PUSH ALERT',
            _notifyOnArrival,
            (val) => setState(() => _notifyOnArrival = val),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.body,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  letterSpacing: 0.5,
                  fontFamily: AppFonts.label,
                ),
              ),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withOpacity(0.2),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey[800],
          ),
        ],
      ),
    );
  }
}
