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
  Map<String, List<Map<String, dynamic>>> _grouped = {};

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
            _grouped = _groupByDate(records);
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
      'TODAY': [],
      'YESTERDAY': [],
      'THIS WEEK': [],
      'OLDER': [],
    };

    for (final r in records) {
      final dt = ApiClient.parseDateTime(r['createdAt']);
      if (dt == null) continue;
      final day = DateTime(dt.year, dt.month, dt.day);
      if (day == today) {
        groups['TODAY']!.add(r);
      } else if (day == yesterday) {
        groups['YESTERDAY']!.add(r);
      } else if (day.isAfter(weekAgo)) {
        groups['THIS WEEK']!.add(r);
      } else {
        groups['OLDER']!.add(r);
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

  @override
  Widget build(BuildContext context) {
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
                  'Activity History',
                  style: TextStyle(
                    fontFamily: AppFonts.headline,
                    fontSize: 32,
                    color: Colors.white,
                  ),
                ),
              ),
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
                      'Error loading activity',
                      style: const TextStyle(color: Colors.grey, fontFamily: AppFonts.body),
                    ),
                  ),
                )
              else if (_grouped.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
                    child: Text(
                      'No activity yet',
                      style: TextStyle(color: Colors.grey, fontFamily: AppFonts.body),
                    ),
                  ),
                )
              else
                ..._grouped.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ActivitySectionHeader(title: entry.key),
                      ...entry.value.map((record) {
                        final dt = ApiClient.parseDateTime(record['createdAt']);
                        final name = record['visitorName'] as String? ?? 'Unknown';
                        final decision = record['decision'] as String?;
                        final type = record['type'] as String? ?? 'walk-in';
                        return ActivityItemCard(
                          visitorName: name,
                          category: type == 'pre-registered' ? 'Pre-registered' : 'Walk-in',
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
