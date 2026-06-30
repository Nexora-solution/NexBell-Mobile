import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';
import '../../../../common/utils/api_client.dart';
import '../widgets/activity_item_card.dart';
import '../widgets/activity_section_header.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _fetchActivity();
  }

  Future<void> _fetchActivity() async {
    try {
      // El historial muestra las visitas pre-registradas del residente que ya
      // fueron decididas (aprobadas/rechazadas). Es la misma fuente que el
      // calendario de inicio; las pendientes se filtran en _showRecord.
      final myResidentId = await ApiClient.getResidentId();
      // El backend filtra por residente (?residentId=) para que un residente
      // nunca reciba las visitas de otro; el filtro local es solo un respaldo.
      final query = myResidentId != null ? '?residentId=$myResidentId' : '';
      final response = await ApiClient.get('/api/intercom/pre-registered-visits$query');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final records = data
            .cast<Map<String, dynamic>>()
            .where((r) => myResidentId == null || r['residentId'] == myResidentId)
            .toList();
        records.sort((a, b) {
          final da = ApiClient.parseDateTime(a['expectedAt']);
          final db = ApiClient.parseDateTime(b['expectedAt']);
          if (da == null || db == null) return 0;
          return db.compareTo(da);
        });
        if (mounted) {
          setState(() {
            _records = records;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() { _error = 'Failed to load activity'; _isLoading = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupByDate(List<Map<String, dynamic>> records) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    final Map<String, List<Map<String, dynamic>>> groups = {
      'HOY': [],
      'AYER': [],
      'ESTA SEMANA': [],
      'ANTERIOR': [],
    };

    for (final r in records) {
      final dt = ApiClient.parseDateTime(r['expectedAt']);
      if (dt == null) continue;
      final day = DateTime(dt.year, dt.month, dt.day);
      if (day == today) {
        groups['HOY']!.add(r);
      } else if (day == yesterday) {
        groups['AYER']!.add(r);
      } else if (day.isAfter(weekAgo)) {
        groups['ESTA SEMANA']!.add(r);
      } else {
        groups['ANTERIOR']!.add(r);
      }
    }

    groups.removeWhere((_, list) => list.isEmpty);
    return groups;
  }

  VisitStatus _toVisitStatus(String? status) {
    switch ((status ?? '').toUpperCase()) {
      case 'APPROVED': return VisitStatus.approved;
      case 'REJECTED': return VisitStatus.rejected;
      default: return VisitStatus.missed;
    }
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '--:--';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  // History only shows visits that were actually decided (approved/rejected).
  // Pending/undecided records never appear here — those live only on the home calendar.
  bool _showRecord(Map<String, dynamic> record) {
    final status = (record['status'] as String? ?? '').toUpperCase();
    return status == 'APPROVED' || status == 'REJECTED';
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDate(_records.where(_showRecord).toList());
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _fetchActivity,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 24.0, bottom: 8.0),
                child: Text(
                  'HISTORIAL DE VISITAS',
                  style: TextStyle(
                    fontFamily: AppFonts.headline,
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Center(
                    child: Text(
                      'Error al cargar el historial',
                      style: const TextStyle(color: Colors.grey, fontFamily: AppFonts.body),
                    ),
                  ),
                )
              else if (grouped.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
                    child: Text(
                      'Todavía no hay actividad.',
                      style: TextStyle(color: Colors.grey, fontFamily: AppFonts.body),
                    ),
                  ),
                )
              else
                ...grouped.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ActivitySectionHeader(title: entry.key),
                      ...entry.value.map((record) {
                        final dt = ApiClient.parseDateTime(record['expectedAt']);
                        final name = record['visitorName'] as String? ?? 'Visitante';
                        final status = record['status'] as String?;
                        final photo = record['visitorPhotoUrl'] as String? ?? '';
                        final document = record['visitorDocument'] as String? ?? '';
                        return ActivityItemCard(
                          visitorName: name,
                          time: _formatTime(dt),
                          status: _toVisitStatus(status),
                          photoUrl: photo.isEmpty ? null : photo,
                          document: document,
                          scheduledAt: dt,
                        );
                      }),
                    ],
                  );
                }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
