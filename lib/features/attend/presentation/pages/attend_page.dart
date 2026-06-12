import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';
import '../../../../common/utils/api_client.dart';

class AttendVisitPage extends StatefulWidget {
  final int visitRequestId;

  const AttendVisitPage({
    super.key,
    required this.visitRequestId,
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
  String _streamToken = '';
  bool isAudioConnected = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // 1. Fetch streaming details
      final streamResponse = await ApiClient.get('/api/intercom/visit-requests/${widget.visitRequestId}/stream');
      if (streamResponse.statusCode == 200) {
        final streamData = jsonDecode(streamResponse.body);
        _streamUrl = streamData['streamUrl'] as String? ?? '';
        _streamToken = streamData['token'] as String? ?? '';
      }

      // 2. Fetch visitor info from pending queue to resolve DNI if possible
      final queueResponse = await ApiClient.get('/api/intercom/queue/pending');
      bool foundInQueue = false;
      if (queueResponse.statusCode == 200) {
        final List queueData = jsonDecode(queueResponse.body);
        final item = queueData.firstWhere(
          (element) => element['visitRequestId'] == widget.visitRequestId,
          orElse: () => null,
        );
        if (item != null) {
          _visitorName = item['visitorName'];
          _visitorDni = item['dni'] == '—' ? null : item['dni'];
          _visitorType = item['type'] ?? 'walk-in';
          foundInQueue = true;
        }
      }

      // 3. Fallback to direct visit request details if not found in queue
      if (!foundInQueue) {
        final detailResponse = await ApiClient.get('/api/intercom/visit-requests/${widget.visitRequestId}');
        if (detailResponse.statusCode == 200) {
          final detailData = jsonDecode(detailResponse.body);
          _visitorName = detailData['visitorName'];
          _visitorDni = null;
          _visitorType = 'walk-in';
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
      final response = await ApiClient.post(
        '/api/intercom/visit-requests/${widget.visitRequestId}/decision',
        body: {'decision': decision},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Visit request $decision')),
          );
          Navigator.pop(context);
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
              
              // Video Container with Overlay
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Stack(
                    children: [
                      // Camera Corner Accents (Brackets)
                      _buildCornerBrackets(),
                      
                      // Stream details overlay
                      Positioned(
                        top: 20,
                        left: 20,
                        right: 20,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'STREAM: $_streamUrl',
                                style: const TextStyle(
                                  color: Colors.white30,
                                  fontSize: 10,
                                  fontFamily: AppFonts.label,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_streamToken.isNotEmpty)
                              Text(
                                'SECURED',
                                style: TextStyle(
                                  color: AppColors.primary.withOpacity(0.7),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: AppFonts.label,
                                ),
                              ),
                          ],
                        ),
                      ),
                      
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
              
              const SizedBox(height: 24),
              
              // Audio Control
              _buildAudioSection(),
              
              const SizedBox(height: 16),
              
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

  Widget _buildAudioSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'AUDIO INPUT',
                style: TextStyle(
                  color: Colors.grey, 
                  fontSize: 10, 
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.label,
                ),
              ),
              Text(
                isAudioConnected ? '00:04 / 00:12' : '00:00 / 00:00',
                style: const TextStyle(
                  color: Colors.grey, 
                  fontSize: 10,
                  fontFamily: AppFonts.label,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => isAudioConnected = !isAudioConnected),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary,
                  child: Icon(
                    isAudioConnected ? Icons.volume_up : Icons.play_arrow,
                    color: AppColors.neutral,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Connect audio',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: AppFonts.body,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
