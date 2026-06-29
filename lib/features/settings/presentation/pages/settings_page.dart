import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';
import '../../../../common/utils/api_client.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../widgets/security_section.dart';
import 'manage_profile_page.dart';
import 'notifications_settings_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = true;
  String _name = '';
  String _initials = '';
  String _apartment = '';
  String _photoUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final response = await ApiClient.get('/api/iam/users/me');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final name = data['fullName'] as String? ?? 'Residente';
        final parts = name.trim().split(RegExp(r'\s+'));
        String initials = '?';
        if (name.trim().isNotEmpty) {
          initials = parts.length > 1
              ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
              : parts[0][0].toUpperCase();
        }

        String apartmentCode = '';
        String photoUrl = '';
        final residentId = data['residentId'];
        if (residentId != null) {
          final resRes = await ApiClient.get('/api/directory/residents/$residentId');
          if (resRes.statusCode == 200) {
            final resData = jsonDecode(resRes.body);
            apartmentCode = resData['apartmentCode'] as String? ?? '';
            photoUrl = resData['photoUrl'] as String? ?? '';
          }
        }

        if (mounted) {
          setState(() {
            _name = name;
            _initials = initials;
            _apartment = apartmentCode;
            _photoUrl = photoUrl;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _name = 'Residente';
          _initials = '?';
          _isLoading = false;
        });
      }
    }
  }

  Uint8List? get _photoBytes {
    if (_photoUrl.isEmpty || !_photoUrl.contains(',')) return null;
    try {
      return base64Decode(_photoUrl.split(',').last);
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleLogout() async {
    final refreshToken = await ApiClient.getRefreshToken();
    if (refreshToken != null) {
      try {
        await ApiClient.post('/api/iam/logout?refreshToken=$refreshToken');
      } catch (_) {}
    }
    await ApiClient.clearAll();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: avatar + name + apartment
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.primary,
                    backgroundImage: _photoBytes != null ? MemoryImage(_photoBytes!) : null,
                    child: _photoBytes == null
                        ? Text(_initials,
                            style: const TextStyle(
                                fontFamily: AppFonts.headline,
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                                color: AppColors.neutral))
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _name,
                    style: const TextStyle(
                        fontFamily: AppFonts.headline, fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
                  ),
                  if (_apartment.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text('Apartamento $_apartment',
                        style: const TextStyle(color: Colors.white54, fontSize: 14, fontFamily: AppFonts.body)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),

            _sectionLabel('ACCOUNT'),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _menuItem(Icons.person_outline, 'Gestionar Perfil', onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ManageProfilePage()),
                    );
                    _fetchProfile();
                  }),
                  _divider(),
                  _menuItem(Icons.lock_outline, 'Contraseña y Seguridad', onTap: () {
                    showDialog(context: context, builder: (_) => const ChangePasswordDialog());
                  }),
                  _divider(),
                  _menuItem(Icons.notifications_none_rounded, 'Notificaciones', onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationsSettingsPage()),
                    );
                  }),
                  _divider(),
                  _menuItem(Icons.language, 'Idioma', trailing: 'Español', onTap: _showLanguageSheet),
                ],
              ),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _handleLogout,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.red.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                    side: BorderSide(color: Colors.red.withOpacity(0.2)),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Cerrar Sesión',
                        style: TextStyle(
                            color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: AppFonts.body)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            ListTile(
              leading: Icon(Icons.check, color: AppColors.primary),
              title: Text('Español', style: TextStyle(color: Colors.white, fontFamily: AppFonts.body)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.bold, fontFamily: AppFonts.label),
      );

  Widget _divider() => const Divider(color: Colors.white10, height: 1, indent: 56);

  Widget _menuItem(IconData icon, String label, {String? trailing, required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.white70, size: 22),
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontFamily: AppFonts.body)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Text(trailing, style: const TextStyle(color: Colors.white38, fontSize: 14, fontFamily: AppFonts.body)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
        ],
      ),
    );
  }
}
