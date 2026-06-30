import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';
import '../../../../common/utils/api_client.dart';

class RecentHistorySection extends StatefulWidget {
  const RecentHistorySection({super.key});

  @override
  State<RecentHistorySection> createState() => _RecentHistorySectionState();
}

class _RecentHistorySectionState extends State<RecentHistorySection> {
  List<Map<String, dynamic>> _records = [];
  bool _isLoading = true;

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
        final sorted = List<Map<String, dynamic>>.from(data.cast<Map<String, dynamic>>());
        sorted.sort((a, b) {
          final da = ApiClient.parseDateTime(a['createdAt']);
          final db = ApiClient.parseDateTime(b['createdAt']);
          if (da == null || db == null) return 0;
          return db.compareTo(da);
        });
        if (mounted) {
          setState(() {
            _records = sorted.take(2).toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatRelativeTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  IconData _iconForDecision(String? decision) {
    if (decision == 'APPROVED') return Icons.door_front_door_outlined;
    if (decision == 'REJECTED') return Icons.block_outlined;
    return Icons.history_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent History",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: AppFonts.headline,
          ),
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
          )
        else if (_records.isEmpty)
          const Text(
            'No recent activity',
            style: TextStyle(color: Colors.grey, fontFamily: AppFonts.body),
          )
        else
          ..._records.map((record) {
            final createdAt = ApiClient.parseDateTime(record['createdAt']);
            final visitorName = record['visitorName'] as String? ?? 'Unknown';
            final decision = record['decision'] as String?;
            final subtitle = '${_formatRelativeTime(createdAt)} • ${decision ?? 'Unknown'}';
            final title = decision == 'APPROVED'
                ? 'Visit Entry: $visitorName'
                : 'Visit Rejected: $visitorName';
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildHistoryItem(_iconForDecision(decision), title, subtitle),
            );
          }),
      ],
    );
  }

  Widget _buildHistoryItem(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFonts.body,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontFamily: AppFonts.label,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
