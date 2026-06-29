import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../common/utils/constants.dart';
import '../../../../common/utils/api_client.dart';
import '../../../auth/presentation/pages/login_page.dart';

/// Visitor fields card (photo, name, DNI) plus the arrival date/time fields.
/// Submission is triggered externally (see [VisitorFormState.submit]) so the
/// "CREAR VISITA" button can live at the bottom of the page, after the
/// recurrence section, instead of being embedded in this card.
class VisitorForm extends StatefulWidget {
  final ValueChanged<bool>? onSubmittingChanged;

  const VisitorForm({super.key, this.onSubmittingChanged});

  @override
  State<VisitorForm> createState() => VisitorFormState();
}

class VisitorFormState extends State<VisitorForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dniController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSubmitting = false;
  Uint8List? _photoBytes;
  String? _photoBase64;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _dniController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined, color: AppColors.primary),
              title: const Text('Tomar foto', style: TextStyle(color: Colors.white, fontFamily: AppFonts.body)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
              title: const Text('Elegir de galería', style: TextStyle(color: Colors.white, fontFamily: AppFonts.body)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    try {
      final picked = await _picker.pickImage(source: source, maxWidth: 800, imageQuality: 80);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() {
        _photoBytes = bytes;
        _photoBase64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo acceder a la cámara/galería: $e')),
        );
      }
    }
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

  void _setSubmitting(bool value) {
    setState(() => _isSubmitting = value);
    widget.onSubmittingChanged?.call(value);
  }

  bool get isSubmitting => _isSubmitting;

  /// Validates and creates the pre-registered visit. Called by the page-level
  /// "CREAR VISITA" button.
  Future<void> submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el nombre del visitante')),
      );
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona fecha y hora de llegada')),
      );
      return;
    }

    _setSubmitting(true);

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
        'visitorPhotoUrl': _photoBase64,
        'expectedAt': expectedAtStr,
      });

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Visita creada correctamente'),
              backgroundColor: AppColors.primary,
            ),
          );
          _nameController.clear();
          _dniController.clear();
          setState(() {
            _selectedDate = null;
            _selectedTime = null;
            _photoBytes = null;
            _photoBase64 = null;
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
          SnackBar(content: Text('Error de conexión: $e')),
        );
      }
    } finally {
      if (mounted) _setSubmitting(false);
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickPhoto,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.black26,
                      backgroundImage: _photoBytes != null ? MemoryImage(_photoBytes!) : null,
                      child: _photoBytes == null
                          ? const Icon(Icons.camera_alt_outlined, color: Colors.white54, size: 28)
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, color: AppColors.neutral, size: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Nombre del Visitante'),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Ej. Roberto García',
                        hintStyle: TextStyle(color: Colors.white24),
                        isDense: true,
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFieldLabel('DNI'),
                    TextField(
                      controller: _dniController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Documento de identidad',
                        hintStyle: TextStyle(color: Colors.white24),
                        isDense: true,
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                      ),
                    ),
                  ],
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
                    _buildFieldLabel('Fecha de llegada'),
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
                                  ? 'dd/mm/yyyy'
                                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
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
                    _buildFieldLabel('Hora aproximada'),
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
                              _selectedTime == null ? '--:--' : _selectedTime!.format(context),
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
