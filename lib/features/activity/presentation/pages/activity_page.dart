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
  // 'all' | 'delivery' | 'personal' — best-effort mapping from the backend's
  // 'type' field (pre-registered visits = Personal; everything else = Delivery)
  // until the backend models proper visit categories.
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _fetchActivity();
  }

  Future<void> _fetchActivity() async {
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
      final dt = ApiClient.parseDateTime(r['createdAt']);
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

  VisitStatus _toVisitStatus(String? decision) {
    switch (decision) {
      case 'APPROVED': return VisitStatus.approved;
      case 'REJECTED': return VisitStatus.rejected;
      default: return VisitStatus.missed;
    }
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '--:--';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  // History only shows visits that were actually decided — pending/undecided
  // records never appear here.
  bool _isDecided(Map<String, dynamic> record) {
    final decision = record['decision'] as String?;
    return decision == 'APPROVED' || decision == 'REJECTED';
  }

  bool _matchesFilter(Map<String, dynamic> record) {
    if (!_isDecided(record)) return false;
    if (_filter == 'all') return true;
    final type = record['type'] as String? ?? 'walk-in';
    final isPersonal = type == 'pre-registered';
    return _filter == 'personal' ? isPersonal : !isPersonal;
  }

  Widget _filterChip(String label, String value) {
    final selected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
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

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDate(_records.where(_matchesFilter).toList());
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
              Row(
                children: [
                  _filterChip('Todos', 'all'),
                  _filterChip('Delivery', 'delivery'),
                  _filterChip('Personal', 'personal'),
                ],
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
                        final dt = ApiClient.parseDateTime(record['createdAt']);
                        final name = record['visitorName'] as String? ?? 'Visitante';
                        final decision = record['decision'] as String?;
                        final type = record['type'] as String? ?? 'walk-in';
                        return ActivityItemCard(
                          visitorName: name,
                          category: type == 'pre-registered' ? 'Personal' : 'Delivery',
                          time: _formatTime(dt),
                          status: _toVisitStatus(decision),
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
