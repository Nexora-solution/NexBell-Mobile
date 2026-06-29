import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';
import '../../../../common/utils/api_client.dart';
import '../../../../common/services/pending_notification_store.dart';
import '../../../attend/presentation/pages/attend_page.dart';

/// Notifications screen: a fallback for when the resident doesn't act on the
/// live push right away. If there is still an unresolved "visit at the door"
/// notification it surfaces it here (tapping it opens the same live-video
/// decision screen the push opens automatically); below that is a read-only
/// history of past visit decisions.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _unreadOnly = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final userId = await ApiClient.getUserId() ?? 0;
      final response = await ApiClient.get('/api/audit/access-records/resident/$userId');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final records = List<Map<String, dynamic>>.from(data.cast<Map<String, dynamic>>());
        records.sort((a, b) {
          final da = ApiClient.parseDateTime(a['createdAt']);
          final db = ApiClient.parseDateTime(b['createdAt']);
          if (da == null || db == null) return 0;
          return db.compareTo(da);
        });
        if (mounted) setState(() { _records = records; _isLoading = false; });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupByDate(List<Map<String, dynamic>> records) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final groups = <String, List<Map<String, dynamic>>>{
      'HOY': [],
      'AYER': [],
      'ANTERIOR': [],
    };
    for (final r in records) {
      final dt = ApiClient.parseDateTime(r['createdAt']);
      if (dt == null) continue;
      final day = DateTime(dt.year, dt.month, dt.day);
      if (day == today) {
        groups['HOY']!.add(r);
      } else if (day == yesterday) {
        groups['AYER']!.add(r);
      } else {
        groups['ANTERIOR']!.add(r);
      }
    }
    groups.removeWhere((_, list) => list.isEmpty);
    return groups;
  }

  String _relativeTime(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    return 'Ayer';
  }

  void _openPending(PendingVisitNotification pending) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AttendVisitPage(
          visitId: pending.visitId,
          visitType: pending.visitType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDate(_records);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'NOTIFICACIONES',
          style: TextStyle(
            fontFamily: AppFonts.headline,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _fetchHistory,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _filterChip('Todas', !_unreadOnly, () => setState(() => _unreadOnly = false)),
                  const SizedBox(width: 10),
                  _filterChip('Sin leer', _unreadOnly, () => setState(() => _unreadOnly = true)),
                ],
              ),
              const SizedBox(height: 20),

              ValueListenableBuilder<PendingVisitNotification?>(
                valueListenable: PendingNotificationStore.current,
                builder: (context, pending, _) {
                  if (pending == null) {
                    if (_unreadOnly) return const SizedBox.shrink();
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('AHORA'),
                      const SizedBox(height: 10),
                      _pendingCard(pending),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),

              if (_unreadOnly)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(
                    child: Text(
                      'No tienes notificaciones sin leer.',
                      style: TextStyle(color: Colors.grey, fontFamily: AppFonts.body),
                    ),
                  ),
                )
              else if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                )
              else if (grouped.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(
                    child: Text(
                      'Sin notificaciones todavía.',
                      style: TextStyle(color: Colors.grey, fontFamily: AppFonts.body),
                    ),
                  ),
                )
              else
                ...grouped.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel(entry.key),
                      const SizedBox(height: 10),
                      ...entry.value.map((r) => _historyRow(r)),
                      const SizedBox(height: 20),
                    ],
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.neutral : Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            fontFamily: AppFonts.body,
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          fontFamily: AppFonts.label,
          letterSpacing: 1,
        ),
      );

  Widget _pendingCard(PendingVisitNotification pending) {
    final initials = (pending.visitorName ?? '?').trim().isEmpty
        ? '?'
        : pending.visitorName!.trim()[0].toUpperCase();
    return GestureDetector(
      onTap: () => _openPending(pending),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'ACCIÓN REQUERIDA',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  fontFamily: AppFonts.label,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: Text(initials,
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pending.visitorName ?? 'Visitante',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.body,
                        ),
                      ),
                      Text(
                        'Visita en puerta · ${_relativeTime(pending.receivedAt)}',
                        style: const TextStyle(color: Colors.white60, fontSize: 12, fontFamily: AppFonts.label),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.videocam_rounded, color: AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _historyRow(Map<String, dynamic> record) {
    final dt = ApiClient.parseDateTime(record['createdAt']);
    final name = record['visitorName'] as String? ?? 'Visitante';
    final decision = record['decision'] as String?;
    final approved = decision == 'APPROVED';
    final initials = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.surface,
            child: Text(initials, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  approved ? '$name fue admitido' : '$name no pudo ingresar',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontFamily: AppFonts.body),
                ),
                Row(
                  children: [
                    Icon(
                      approved ? Icons.check_circle : Icons.cancel,
                      color: approved ? const Color(0xFF6BD38A) : const Color(0xFFE57373),
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      approved ? 'Aprobaste su ingreso' : 'Acceso denegado',
                      style: const TextStyle(color: Colors.white38, fontSize: 12, fontFamily: AppFonts.label),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            dt != null
                ? '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'
                : '',
            style: const TextStyle(color: Colors.white38, fontSize: 12, fontFamily: AppFonts.label),
          ),
        ],
      ),
    );
  }
}
