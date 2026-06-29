import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';

/// Local notification preferences. These are device-side toggles only (the
/// resident always receives door push notifications); kept simple until the
/// backend exposes per-resident notification settings.
class NotificationsSettingsPage extends StatefulWidget {
  const NotificationsSettingsPage({super.key});

  @override
  State<NotificationsSettingsPage> createState() => _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  bool _visitAlerts = true;
  bool _sound = true;
  bool _vibration = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Notificaciones',
          style: TextStyle(fontFamily: AppFonts.headline, fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                _toggle('Alertas de visita', 'Avisarme cuando llegue una visita', _visitAlerts,
                    (v) => setState(() => _visitAlerts = v)),
                const Divider(color: Colors.white10, height: 1),
                _toggle('Sonido', 'Reproducir sonido al recibir una alerta', _sound,
                    (v) => setState(() => _sound = v)),
                const Divider(color: Colors.white10, height: 1),
                _toggle('Vibración', 'Vibrar al recibir una alerta', _vibration,
                    (v) => setState(() => _vibration = v)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggle(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.primary,
      activeTrackColor: AppColors.primary.withOpacity(0.3),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontFamily: AppFonts.body)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12, fontFamily: AppFonts.label)),
    );
  }
}
