import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';
import '../../../../common/utils/api_client.dart';
import '../../../auth/presentation/pages/login_page.dart';

class VisitorForm extends StatefulWidget {
  const VisitorForm({super.key});

  @override
  State<VisitorForm> createState() => _VisitorFormState();
}

class _VisitorFormState extends State<VisitorForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dniController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dniController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.neutral,
              surface: AppColors.surface,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.neutral,
              surface: AppColors.surface,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _refreshResidentId() async {
    try {
      final profileRes = await ApiClient.get('/api/iam/users/me');
      if (profileRes.statusCode == 401) {
        await ApiClient.clearAll();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (_) => false,
          );
        }
        return;
      }
      if (profileRes.statusCode != 200) return;
      final profile = jsonDecode(profileRes.body);
      final userId = profile['id'] as int?;
      if (userId == null) return;
      final apartmentId = profile['apartmentId'] as int?;
      final residentId = (profile['residentId'] as int?) ?? userId;
      await ApiClient.saveUserData(
        userId: userId,
        apartmentId: apartmentId ?? 0,
        residentId: residentId,
      );
    } catch (_) {}
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the visitor name')),
      );
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select arrival date and time')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      int? residentId = await ApiClient.getResidentId();

      // If residentId was never saved (old session), fetch fresh from backend
      if (residentId == null) {
        await _refreshResidentId();
        residentId = await ApiClient.getResidentId();
      }

      if (residentId == null) {
        // Last resort: fetch profile and show exact error
        final profileRes = await ApiClient.get('/api/iam/users/me');
        if (profileRes.statusCode == 401) {
          await ApiClient.clearAll();
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (_) => false,
            );
          }
          return;
        }
        final errorDetail = 'Profile status: ${profileRes.statusCode} | ${profileRes.body.length > 120 ? profileRes.body.substring(0, 120) : profileRes.body}';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorDetail), duration: const Duration(seconds: 8)),
          );
        }
        return;
      }

      final expectedAt = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      final expectedAtStr = '${expectedAt.year}-'
          '${expectedAt.month.toString().padLeft(2, '0')}-'
          '${expectedAt.day.toString().padLeft(2, '0')}T'
          '${expectedAt.hour.toString().padLeft(2, '0')}:'
          '${expectedAt.minute.toString().padLeft(2, '0')}:00';

      final response = await ApiClient.post('/api/intercom/pre-registered-visits', body: {
        'residentId': residentId,
        'visitorName': name,
        'visitorDocument': _dniController.text.trim(),
        'expectedAt': expectedAtStr,
      });

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pre-authorization created successfully'),
              backgroundColor: AppColors.primary,
            ),
          );
          _nameController.clear();
          _dniController.clear();
          setState(() {
            _selectedDate = null;
            _selectedTime = null;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.body}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldLabel('Visitor'),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'e.g. Roberto Garcia',
                  hintStyle: TextStyle(color: Colors.white24),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                ),
              ),
              const SizedBox(height: 20),
              _buildFieldLabel('DNI'),
              TextField(
                controller: _dniController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Identity Document',
                  hintStyle: TextStyle(color: Colors.white24),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Arrival Date'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDate == null
                                  ? 'mm/dd/yyyy'
                                  : '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}',
                              style: TextStyle(
                                color: _selectedDate == null ? Colors.white24 : Colors.white,
                              ),
                            ),
                            const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.white54),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Approx. Time'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectTime(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedTime == null ? '-- : --' : _selectedTime!.format(context),
                              style: TextStyle(
                                color: _selectedTime == null ? Colors.white24 : Colors.white,
                              ),
                            ),
                            const Icon(Icons.access_time, size: 16, color: Colors.white54),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.neutral,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: AppColors.neutral, strokeWidth: 2),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Generate Pre-authorization',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.body,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.shield_outlined, size: 20),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        fontFamily: AppFonts.label,
      ),
    );
  }
}
