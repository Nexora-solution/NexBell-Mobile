import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';
import '../../../../common/utils/image_utils.dart';
import '../widgets/activity_item_card.dart';

class VisitDetailPage extends StatelessWidget {
  final String visitorName;
  final VisitStatus status;
  final String? photoUrl;
  final String document;
  final DateTime? scheduledAt;

  const VisitDetailPage({
    super.key,
    required this.visitorName,
    required this.status,
    this.photoUrl,
    this.document = '',
    this.scheduledAt,
  });

  @override
  Widget build(BuildContext context) {
    final image = avatarImageProvider(photoUrl);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header card: foto + nombre + estado ───────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withOpacity(0.15),
                    backgroundImage: image,
                    child: image == null
                        ? const Icon(Icons.person, size: 50, color: Colors.white54)
                        : null,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    visitorName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontFamily: AppFonts.headline,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildStatusBadge(),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Datos del registro ────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 4),
                    child: Text(
                      'DATOS DEL REGISTRO',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        fontFamily: AppFonts.label,
                      ),
                    ),
                  ),
                  _row('Nombre', visitorName, valueBold: true),
                  _divider(),
                  _row('DNI', document.trim().isEmpty ? '—' : document.trim()),
                  _divider(),
                  _row('Programado', _formatScheduled(scheduledAt), valueColor: AppColors.primary),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String label;
    IconData icon;
    switch (status) {
      case VisitStatus.approved:
        color = AppColors.primary;
        label = 'Acceso Autorizado';
        icon = Icons.check_circle;
        break;
      case VisitStatus.rejected:
        color = Colors.redAccent;
        label = 'Acceso Denegado';
        icon = Icons.cancel;
        break;
      case VisitStatus.missed:
        color = Colors.orangeAccent;
        label = 'No atendido';
        icon = Icons.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool valueBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 15, fontFamily: AppFonts.body),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: 15,
                fontWeight: valueBold ? FontWeight.bold : FontWeight.w500,
                fontFamily: AppFonts.body,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(color: Colors.white10, height: 1);

  static const _months = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
  ];

  /// Formats the scheduled date as "14 de mayo, 14:00". Returns "—" when null.
  String _formatScheduled(DateTime? dt) {
    if (dt == null) return '—';
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} de ${_months[dt.month - 1]}, $hh:$mm';
  }
}
