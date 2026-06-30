import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../common/utils/constants.dart';
import '../../../../common/utils/api_client.dart';

/// "Gestionar Perfil": shows the resident's profile (photo, name, contact,
/// residential unit) read-only, with an "Editar Perfil" toggle to edit the
/// name, phone and profile photo. The unit is locked (not editable).
class ManageProfilePage extends StatefulWidget {
  const ManageProfilePage({super.key});

  @override
  State<ManageProfilePage> createState() => _ManageProfilePageState();
}

class _ManageProfilePageState extends State<ManageProfilePage> {
  bool _loading = true;
  bool _editing = false;
  bool _saving = false;

  int? _residentId;
  String _name = '';
  String _email = '';
  String _phone = '';
  String _apartment = '';
  String _photoUrl = '';
  Uint8List? _newPhotoBytes;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final meRes = await ApiClient.get('/api/iam/users/me');
      if (meRes.statusCode != 200) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      final me = jsonDecode(meRes.body);
      final residentId = me['residentId'] as int?;
      _email = me['email'] as String? ?? '';

      if (residentId != null) {
        final res = await ApiClient.get('/api/directory/residents/$residentId');
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          _residentId = residentId;
          _name = data['fullName'] as String? ?? '';
          _email = data['email'] as String? ?? _email;
          _phone = data['phone'] as String? ?? '';
          _apartment = data['apartmentCode'] as String? ?? '';
          _photoUrl = data['photoUrl'] as String? ?? '';
        }
      }
      _nameController.text = _name;
      _phoneController.text = _phone;
      if (mounted) setState(() => _loading = false);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _handle {
    final local = _email.contains('@') ? _email.split('@').first : _email;
    return local.isEmpty ? '@residente' : '@$local';
  }

  Uint8List? get _avatarBytes {
    if (_newPhotoBytes != null) return _newPhotoBytes;
    if (_photoUrl.isNotEmpty && _photoUrl.contains(',')) {
      try {
        return base64Decode(_photoUrl.split(',').last);
      } catch (_) {}
    }
    return null;
  }

  String get _initials {
    final parts = _name.trim().split(RegExp(r'\s+'));
    if (_name.trim().isEmpty) return '?';
    return parts.length > 1
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : parts[0][0].toUpperCase();
  }

  Future<void> _pickPhoto() async {
    if (!_editing) return;
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
      final picked = await _picker.pickImage(source: source, maxWidth: 600, imageQuality: 80);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() => _newPhotoBytes = bytes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo acceder a la cámara/galería: $e')),
        );
      }
    }
  }

  Future<void> _save() async {
    if (_residentId == null) return;
    setState(() => _saving = true);
    try {
      final body = <String, String>{
        'fullName': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
      };
      if (_newPhotoBytes != null) {
        body['photoUrl'] = 'data:image/jpeg;base64,${base64Encode(_newPhotoBytes!)}';
      }
      final res = await ApiClient.put('/api/directory/residents/$_residentId/contact', body: body);
      if (res.statusCode == 200) {
        setState(() {
          _name = _nameController.text.trim();
          _phone = _phoneController.text.trim();
          if (_newPhotoBytes != null) {
            _photoUrl = body['photoUrl']!;
            _newPhotoBytes = null;
          }
          _editing = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil actualizado'), backgroundColor: AppColors.primary),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se pudo guardar (${res.statusCode})')),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error de conexión al guardar.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Gestionar Perfil',
          style: TextStyle(fontFamily: AppFonts.headline, fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _pickPhoto,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: AppColors.primary,
                              backgroundImage: _avatarBytes != null ? MemoryImage(_avatarBytes!) : null,
                              child: _avatarBytes == null
                                  ? Text(_initials,
                                      style: const TextStyle(
                                          color: AppColors.neutral,
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: AppFonts.headline))
                                  : null,
                            ),
                            if (_editing)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(color: AppColors.selected, shape: BoxShape.circle),
                                  child: const Icon(Icons.edit, color: Colors.white, size: 14),
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
                            Text(
                              _name.isEmpty ? 'Residente' : _name,
                              style: const TextStyle(
                                  fontFamily: AppFonts.headline,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Colors.white),
                            ),
                            const SizedBox(height: 2),
                            Text(_handle,
                                style: const TextStyle(color: Colors.white38, fontSize: 13, fontFamily: AppFonts.body)),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: _saving
                                  ? null
                                  : () {
                                      if (_editing) {
                                        _save();
                                      } else {
                                        setState(() => _editing = true);
                                      }
                                    },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _editing ? AppColors.primary : AppColors.selected,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: _saving
                                    ? const SizedBox(
                                        height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : Text(
                                        _editing ? 'Guardar' : 'Editar Perfil',
                                        style: TextStyle(
                                          color: _editing ? AppColors.neutral : Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          fontFamily: AppFonts.body,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _editableRow('NOMBRE COMPLETO', _nameController, _name),
                        const Divider(color: Colors.white10, height: 28),
                        _readonlyRow('CORREO ELECTRÓNICO', _email),
                        const Divider(color: Colors.white10, height: 28),
                        _editableRow('TELÉFONO', _phoneController, _phone, keyboard: TextInputType.phone),
                        const Divider(color: Colors.white10, height: 28),
                        _readonlyRow(
                          'UNIDAD RESIDENCIAL',
                          _apartment.isEmpty ? '—' : 'Depto. $_apartment',
                          locked: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 0.5, fontFamily: AppFonts.label),
      );

  Widget _editableRow(String label, TextEditingController controller, String value, {TextInputType? keyboard}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 4),
        _editing
            ? TextField(
                controller: controller,
                keyboardType: keyboard,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: AppFonts.body),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.only(bottom: 6),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                ),
              )
            : Text(value.isEmpty ? '—' : value,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: AppFonts.body)),
      ],
    );
  }

  Widget _readonlyRow(String label, String value, {bool locked = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _label(label),
            if (locked) const Icon(Icons.lock_outline, color: Colors.white24, size: 14),
          ],
        ),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(color: locked ? Colors.white54 : Colors.white, fontSize: 16, fontFamily: AppFonts.body)),
      ],
    );
  }
}
