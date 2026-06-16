import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';
import '../../../../common/utils/api_client.dart';

class TodayVisitsSection extends StatefulWidget {
  final VoidCallback onSeeAll;

  const TodayVisitsSection({super.key, required this.onSeeAll});

  @override
  State<TodayVisitsSection> createState() => _TodayVisitsSectionState();
}

class _TodayVisitsSectionState extends State<TodayVisitsSection> {
  List<Map<String, dynamic>> _visits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTodayVisits();
  }

  Future<void> _fetchTodayVisits() async {
    try {
      final userId = await ApiClient.getUserId() ?? 0;
      final response = await ApiClient.get('/api/audit/access-records/resident/$userId');
      if (response.statusCode == 200) {
        final List<dynamic> records = jsonDecode(response.body);
        final today = DateTime.now();
        final todayVisits = records.where((r) {
          final createdAt = ApiClient.parseDateTime(r['createdAt']);
          if (createdAt == null) return false;
          return createdAt.year == today.year &&
              createdAt.month == today.month &&
              createdAt.day == today.day;
        }).toList();

        if (mounted) {
          setState(() {
            _visits = todayVisits.cast<Map<String, dynamic>>();
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

  IconData _iconForType(String? type) {
    switch (type) {
      case 'pre-registered':
        return Icons.person_outline;
      default:
        return Icons.door_front_door_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Today's Visits",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.headline,
              ),
            ),
            TextButton(
              onPressed: widget.onSeeAll,
              child: const Text(
                'See All',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.label,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isLoading)
          const SizedBox(
            height: 70,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
            ),
          )
        else if (_visits.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'No visits today',
              style: TextStyle(color: Colors.grey, fontFamily: AppFonts.body),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _visits.map((visit) {
                final createdAt = ApiClient.parseDateTime(visit['createdAt']);
                final time = createdAt != null
                    ? '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}'
                    : '--:--';
                final name = visit['visitorName'] as String? ?? 'Unknown';
                final type = visit['type'] as String?;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildVisitPill(_iconForType(type), name, time),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildVisitPill(IconData icon, String name, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: AppFonts.body,
            ),
          ),
          const SizedBox(width: 8),
          const Text('•', style: TextStyle(color: Colors.grey)),
          const SizedBox(width: 8),
          Text(
            time,
            style: const TextStyle(color: Colors.grey, fontFamily: AppFonts.label),
          ),
        ],
      ),
    );
  }
}
