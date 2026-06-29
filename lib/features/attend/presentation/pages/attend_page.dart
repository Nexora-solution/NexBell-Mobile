import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';
import '../../../../common/utils/api_client.dart';
import '../../../../common/config/api_config.dart';
import '../../../../common/services/pending_notification_store.dart';
import '../widgets/mjpeg_view.dart';

class AttendVisitPage extends StatefulWidget {
  final int visitId;
  /// "VISIT_REQUEST" (ad-hoc walk-in flow) or "PRE_REGISTERED_VISIT" (the
  /// resident's own pre-registered visitor) — determines which backend
  /// endpoints this page calls for [visitId].
  final String visitType;

  const AttendVisitPage({
    super.key,
    required this.visitId,
    this.visitType = 'VISIT_REQUEST',
  });

  @override
  State<AttendVisitPage> createState() => _AttendVisitPageState();
}

class _AttendVisitPageState extends State<AttendVisitPage> {
  bool _isLoading = true;
  String? _visitorName;
  String? _visitorDni;
  String _visitorType = 'walk-in';
  String _streamUrl = '';

  /// null = still deciding; 'APPROVED'/'REJECTED' = decision made, showing
  /// the confirmation screen before returning to the home screen.
  String? _decisionResult;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  bool get _isPreRegistered => widget.visitType == 'PRE_REGISTERED_VISIT';

  Future<void> _loadData() async {
    try {
      if (_isPreRegistered) {
        // The camera is a single global feed — no per-visit stream lookup needed.
        _streamUrl = '${apiBase()}/api/intercom/video-stream';

        final detailResponse = await ApiClient.get('/api/intercom/pre-registered-visits/${widget.visitId}');
        if (detailResponse.statusCode == 200) {
          final detailData = jsonDecode(detailResponse.body);
          _visitorName = detailData['visitorName'];
          _visitorDni = detailData['visitorDocument'];
          _visitorType = 'pre-registered';
        }
      } else {
        // 1. Fetch streaming details
        final streamResponse = await ApiClient.get('/api/intercom/visit-requests/${widget.visitId}/stream');
        if (streamResponse.statusCode == 200) {
          final streamData = jsonDecode(streamResponse.body);
          final relativeUrl = streamData['streamUrl'] as String? ?? '';
          _streamUrl = relativeUrl.startsWith('http') ? relativeUrl : '${apiBase()}$relativeUrl';
        }

        // 2. Fetch visitor info from pending queue to resolve DNI if possible
        final queueResponse = await ApiClient.get('/api/intercom/queue/pending');
        bool foundInQueue = false;
        if (queueResponse.statusCode == 200) {
          final List queueData = jsonDecode(queueResponse.body);
          final item = queueData.firstWhere(
            (element) => element['visitRequestId'] == widget.visitId,
            orElse: () => null,
          );
          if (item != null) {
            _visitorName = item['visitorName'];
            _visitorDni = item['dni'] == '—' ? null : item['dni'];
            _visitorType = item['type'] ?? 'walk-in';
            foundInQueue = true;
          }
        }

        // 3. Fetch visit request details (fallback visitor details if not found in queue)
        if (!foundInQueue) {
          final detailResponse = await ApiClient.get('/api/intercom/visit-requests/${widget.visitId}');
          if (detailResponse.statusCode == 200) {
            final detailData = jsonDecode(detailResponse.body);
            _visitorName = detailData['visitorName'];
            _visitorDni = null;
            _visitorType = 'walk-in';
          }
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading visit details: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitDecision(String decision) async {
    try {
      final path = _isPreRegistered
          ? '/api/intercom/pre-registered-visits/${widget.visitId}/decision'
          : '/api/intercom/visit-requests/${widget.visitId}/decision';
      final response = _isPreRegistered
          ? await ApiClient.put(path, body: {'decision': decision})
          : await ApiClient.post(path, body: {'decision': decision});

      if (response.statusCode == 200) {
        if (PendingNotificationStore.current.value?.visitId == widget.visitId) {
          PendingNotificationStore.clear();
        }
        if (mounted) {
          setState(() => _decisionResult = decision);
          // Show the confirmation screen briefly, then return to the home screen.
          Timer(const Duration(seconds: 2), () {
            if (mounted) Navigator.pop(context);
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to submit decision')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (_decisionResult != null) {
      return _buildConfirmationScreen();
    }

    bool isIdentified = _visitorType == 'pre-registered';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Header
              const Text(
                'New Visit at the Door',
                style: TextStyle(
                  fontFamily: AppFonts.headline,
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(radius: 3, backgroundColor: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'LIVE • MAIN ENTRANCE',
                    style: TextStyle(
                      fontFamily: AppFonts.label,
                      fontSize: 12,
                      color: AppColors.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Live video container
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Stack(
                      children: [
                        // Live camera feed from the ESP32 (same endpoint the web uses)
                        if (_streamUrl.isNotEmpty)
                          Positioned.fill(
                            child: MjpegView(
                              url: _streamUrl,
                              placeholder: const Center(
                                child: Icon(Icons.videocam_off, color: Colors.white24, size: 48),
                              ),
                            ),
                          ),
                        _buildCornerBrackets(),

                        // Visitor Info Overlay (Bottom)
                        Positioned(
                          bottom: 40,
                          left: 30,
                          right: 30,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isIdentified)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'IDENTIFIED',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                _visitorName ?? "Visitor",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontFamily: AppFonts.headline,
                                ),
                              ),
                              if (isIdentified && _visitorDni != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'DNI: $_visitorDni',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    fontFamily: AppFonts.body,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              _buildLargeButton(
                label: 'Open Door',
                icon: Icons.vpn_key_outlined,
                backgroundColor: AppColors.primary,
                textColor: AppColors.neutral,
                onTap: () => _submitDecision('APPROVED'),
              ),
              const SizedBox(height: 12),
              _buildLargeButton(
                label: 'Ignore',
                icon: Icons.block,
                backgroundColor: Colors.transparent,
                textColor: Colors.redAccent,
                borderColor: Colors.redAccent.withOpacity(0.3),
                onTap: () => _submitDecision('REJECTED'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmationScreen() {
    final approved = _decisionResult == 'APPROVED';
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              approved ? Icons.check_circle : Icons.cancel,
              color: approved ? AppColors.primary : Colors.redAccent,
              size: 72,
            ),
            const SizedBox(height: 20),
            Text(
              approved ? 'Acceso aprobado' : 'Visita rechazada',
              style: const TextStyle(
                fontFamily: AppFonts.headline,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              approved
                  ? 'Le avisamos al portero que puede dejar entrar a ${_visitorName ?? "el visitante"}.'
                  : 'Le avisamos al portero que la visita fue rechazada.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerBrackets() {
    return Stack(
      children: [
        Positioned(top: 20, left: 20, child: _bracket(top: true, left: true)),
        Positioned(top: 20, right: 20, child: _bracket(top: true, left: false)),
        Positioned(bottom: 20, left: 20, child: _bracket(top: false, left: true)),
        Positioned(bottom: 20, right: 20, child: _bracket(top: false, left: false)),
      ],
    );
  }

  Widget _bracket({required bool top, required bool left}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          top: top ? const BorderSide(color: Colors.white24, width: 2) : BorderSide.none,
          bottom: !top ? const BorderSide(color: Colors.white24, width: 2) : BorderSide.none,
          left: left ? const BorderSide(color: Colors.white24, width: 2) : BorderSide.none,
          right: !left ? const BorderSide(color: Colors.white24, width: 2) : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildLargeButton({
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: borderColor != null ? BorderSide(color: borderColor) : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
