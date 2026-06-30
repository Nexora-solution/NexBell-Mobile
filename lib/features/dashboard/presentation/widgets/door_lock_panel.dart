import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';
import '../../../../common/utils/api_client.dart';

class DoorLockPanel extends StatefulWidget {
  const DoorLockPanel({super.key});

  @override
  State<DoorLockPanel> createState() => _DoorLockPanelState();
}

class _DoorLockPanelState extends State<DoorLockPanel> {
  bool _isLocked = true;
  bool _isOnline = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _fetchDoorStatus();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _fetchDoorStatus();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchDoorStatus() async {
    try {
      final response = await ApiClient.get('/api/security/door/status');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['status'] as String? ?? 'LOCKED';
        final online = data['online'] as bool? ?? true;
        if (mounted) {
          setState(() {
            _isLocked = (status == 'LOCKED');
            _isOnline = online;
          });
        }
      }
    } catch (e) {
      // Background polling: fail silently to avoid UI disruption
    }
  }

  Future<void> _toggleLock() async {
    final newLockedState = !_isLocked;
    // Optimistic UI update
    setState(() {
      _isLocked = newLockedState;
    });

    try {
      final endpoint = newLockedState ? '/api/security/door/lock' : '/api/security/door/unlock';
      final response = await ApiClient.post(endpoint);

      if (response.statusCode != 200) {
        // Revert on failure
        setState(() {
          _isLocked = !newLockedState;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update door status')),
          );
        }
      }
    } catch (e) {
      // Revert on exception
      setState(() {
        _isLocked = !newLockedState;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error communicating with door: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleLock,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: _isLocked ? Colors.transparent : AppColors.primary.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isLocked ? Colors.white10 : AppColors.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                _isLocked ? Icons.lock_outline : Icons.lock_open_outlined,
                size: 48,
                color: _isLocked ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _isLocked ? 'Lock Secured' : 'Lock Unlocked',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.headline,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'MAIN DOOR • ${_isOnline ? "ONLINE" : "OFFLINE"}',
              style: TextStyle(
                color: _isLocked ? Colors.grey : AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                fontFamily: AppFonts.label,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
