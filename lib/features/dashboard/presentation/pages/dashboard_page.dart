import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';
import '../../../../common/utils/api_client.dart';
import '../widgets/mini_calendar.dart';

class DashboardPage extends StatefulWidget {
  final VoidCallback onPreAuthorize;
  final VoidCallback onSeeAllVisits;

  const DashboardPage({
    super.key,
    required this.onPreAuthorize,
    required this.onSeeAllVisits,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _firstName = '';
  String _apartmentCode = '';
  bool _isLoadingProfile = true;

  List<Map<String, dynamic>> _allRecords = [];
  bool _isLoadingVisits = true;

  late DateTime _displayedMonth;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month, 1);
    _selectedDay = DateTime(now.year, now.month, now.day);
    _fetchProfile();
    _fetchVisits();
  }

  Future<void> _fetchProfile() async {
    try {
      final profileRes = await ApiClient.get('/api/iam/users/me');
      if (profileRes.statusCode != 200) return;
      final profile = jsonDecode(profileRes.body);
      final fullName = profile['fullName'] as String? ?? '';
      final residentId = profile['residentId'];
      String apartmentCode = '';
      if (residentId != null) {
        final resRes = await ApiClient.get('/api/directory/residents/$residentId');
        if (resRes.statusCode == 200) {
          final resData = jsonDecode(resRes.body);
          apartmentCode = resData['apartmentCode'] as String? ?? '';
        }
      }
      if (mounted) {
        setState(() {
          _firstName = fullName.trim().isEmpty ? '' : fullName.trim().split(RegExp(r'\s+')).first;
          _apartmentCode = apartmentCode;
          _isLoadingProfile = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  // The dashboard shows the visits the resident scheduled themselves
  // (pre-registered visits), keyed by their expected arrival date — so a
  // visitor expected on the 30th shows a dot on the 30th and a card when that
  // day is selected.
  Future<void> _fetchVisits() async {
    try {
      final myResidentId = await ApiClient.getResidentId();
      final response = await ApiClient.get('/api/intercom/pre-registered-visits');
      if (response.statusCode == 200) {
        final List<dynamic> records = jsonDecode(response.body);
        final mine = records
            .cast<Map<String, dynamic>>()
            .where((r) => myResidentId == null || r['residentId'] == myResidentId)
            .toList();
        if (mounted) {
          setState(() {
            _allRecords = mine;
            _isLoadingVisits = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingVisits = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingVisits = false);
    }
  }

  Set<int> get _daysWithVisitsInDisplayedMonth {
    final days = <int>{};
    for (final r in _allRecords) {
      final dt = ApiClient.parseDateTime(r['expectedAt']);
      if (dt == null) continue;
      if (dt.year == _displayedMonth.year && dt.month == _displayedMonth.month) {
        days.add(dt.day);
      }
    }
    return days;
  }

  List<Map<String, dynamic>> get _visitsOnSelectedDay {
    return _allRecords.where((r) {
      final dt = ApiClient.parseDateTime(r['expectedAt']);
      if (dt == null) return false;
      return dt.year == _selectedDay.year &&
          dt.month == _selectedDay.month &&
          dt.day == _selectedDay.day;
    }).toList();
  }

  bool get _isToday {
    final now = DateTime.now();
    return _selectedDay.year == now.year && _selectedDay.month == now.month && _selectedDay.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final visits = _visitsOnSelectedDay;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (_isLoadingProfile || _firstName.isEmpty) ? 'Hola' : 'Hola, $_firstName',
              style: const TextStyle(
                fontFamily: AppFonts.headline,
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: Colors.white,
              ),
            ),
            if (_apartmentCode.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'DEPTO. $_apartmentCode',
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  fontFamily: AppFonts.label,
                ),
              ),
            ],
            const SizedBox(height: 10),
            const Text(
              '¿Listo para recibir a tus visitas hoy?',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontFamily: AppFonts.body,
              ),
            ),
            const SizedBox(height: 20),

            // Calendar card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.35)),
              ),
              child: MiniCalendar(
                displayedMonth: _displayedMonth,
                selectedDay: _selectedDay,
                daysWithVisits: _daysWithVisitsInDisplayedMonth,
                onMonthChanged: (month) => setState(() => _displayedMonth = month),
                onDaySelected: (day) => setState(() => _selectedDay = day),
              ),
            ),
            const SizedBox(height: 20),

            // Selected day's visits card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isToday
                            ? 'VISITAS DE HOY'
                            : 'VISITAS DEL ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          fontFamily: AppFonts.label,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onSeeAllVisits,
                        child: const Text(
                          'Ver todo',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppFonts.label,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (_isLoadingVisits)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                      ),
                    )
                  else if (visits.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        _isToday
                            ? 'No tienes visitas programadas hoy.'
                            : 'No hay visitas registradas ese día.',
                        style: const TextStyle(color: Colors.white38, fontFamily: AppFonts.body, fontSize: 13),
                      ),
                    )
                  else
                    ...visits.map((v) => _visitRow(v)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _visitRow(Map<String, dynamic> visit) {
    final dt = ApiClient.parseDateTime(visit['expectedAt']);
    final time = dt != null
        ? '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'
        : '--:--';
    final name = visit['visitorName'] as String? ?? 'Visitante';
    final status = (visit['status'] as String? ?? 'PENDING').toUpperCase();
    final isPending = status != 'APPROVED' && status != 'REJECTED';
    final initials = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    final photoUrl = visit['visitorPhotoUrl'] as String? ?? '';
    final photoBytes = _decodeDataUrl(photoUrl);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              backgroundImage: photoBytes != null ? MemoryImage(photoBytes) : null,
              child: photoBytes == null
                  ? Text(initials, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold, fontFamily: AppFonts.body)),
                  Text(time, style: const TextStyle(color: Colors.white38, fontSize: 12, fontFamily: AppFonts.label)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isPending
                    ? const Color(0xFFFFC882).withOpacity(0.15)
                    : (status == 'APPROVED'
                        ? const Color(0xFF6BD38A).withOpacity(0.15)
                        : const Color(0xFFE57373).withOpacity(0.15)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isPending ? 'Pendiente' : (status == 'APPROVED' ? 'Aprobado' : 'Rechazado'),
                style: TextStyle(
                  color: isPending
                      ? const Color(0xFFFFC882)
                      : (status == 'APPROVED' ? const Color(0xFF6BD38A) : const Color(0xFFE57373)),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.label,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Decodes a base64 data URL ("data:image/...;base64,XXXX") to bytes, or
  /// null if there's no usable image.
  Uint8List? _decodeDataUrl(String dataUrl) {
    if (dataUrl.isEmpty || !dataUrl.contains(',')) return null;
    try {
      return base64Decode(dataUrl.split(',').last);
    } catch (_) {
      return null;
    }
  }
}
