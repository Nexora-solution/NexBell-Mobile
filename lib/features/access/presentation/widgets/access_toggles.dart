import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';

/// Cosmetic recurrence controls — the backend only supports a single
/// `expectedAt` per pre-registered visit today, so this section is visual
/// only for now (the visit is still created as a one-time entry).
class AccessToggles extends StatefulWidget {
  const AccessToggles({super.key});

  @override
  State<AccessToggles> createState() => _AccessTogglesState();
}

class _AccessTogglesState extends State<AccessToggles> {
  bool _isRecurring = false;
  final Set<int> _selectedDays = {1}; // 0=L .. 6=D, default Monday picked like the mockup
  static const _dayLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '¿Repetir esta visita?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.body,
                  ),
                ),
                Switch(
                  value: _isRecurring,
                  onChanged: (val) => setState(() => _isRecurring = val),
                  activeThumbColor: AppColors.primary,
                  activeTrackColor: AppColors.primary.withOpacity(0.2),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey[800],
                ),
              ],
            ),
          ),
          if (_isRecurring) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DÍAS DE LA SEMANA',
                    style: TextStyle(color: Colors.grey, fontSize: 11, fontFamily: AppFonts.label, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (i) {
                      final selected = _selectedDays.contains(i);
                      return GestureDetector(
                        onTap: () => setState(() {
                          selected ? _selectedDays.remove(i) : _selectedDays.add(i);
                        }),
                        child: Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primary : Colors.black26,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            _dayLabels[i],
                            style: TextStyle(
                              color: selected ? AppColors.neutral : Colors.white54,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'REPETIR HASTA',
                    style: TextStyle(color: Colors.grey, fontSize: 11, fontFamily: AppFonts.label, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _dateBox('dd/mm/yyyy')),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('a', style: TextStyle(color: Colors.white38)),
                      ),
                      Expanded(child: _dateBox('dd/mm/yyyy')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _dateBox(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(hint, style: const TextStyle(color: Colors.white24, fontSize: 13)),
    );
  }
}
