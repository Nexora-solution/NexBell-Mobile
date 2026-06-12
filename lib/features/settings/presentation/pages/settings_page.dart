import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';
import '../../../../common/utils/api_client.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../widgets/profile_header.dart';
import '../widgets/personal_info_section.dart';
import '../widgets/security_section.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = true;
  String _name = '';
  String _email = '';
  String _role = '';
  String _initials = '';

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
        final name = data['fullName'] as String? ?? 'Resident User';
        final email = data['email'] as String? ?? '';
        final role = data['role'] as String? ?? 'Resident';

        // Calculate initials
        String initials = 'RU';
        final parts = name.trim().split(RegExp(r'\s+'));
        if (parts.isNotEmpty) {
          if (parts.length > 1) {
            initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
          } else if (parts[0].isNotEmpty) {
            initials = parts[0][0].toUpperCase();
          }
        }

        if (mounted) {
          setState(() {
            _name = name;
            _email = email;
            _role = role;
            _initials = initials;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: ${e.toString()}')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    await ApiClient.clearToken();
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
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    final tier = _role.toUpperCase() == 'RESIDENT' ? 'Resident Security Tier' : '${_role[0].toUpperCase()}${_role.substring(1)} Security Tier';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            children: [
              ProfileHeader(
                name: _name,
                tier: tier,
                initials: _initials,
              ),
              const SizedBox(height: 32),
              PersonalInfoSection(
                initialName: _name,
                initialEmail: _email,
              ),
              const SizedBox(height: 24),
              const SecuritySection(),
              const SizedBox(height: 40),
              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
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
                        Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppFonts.body,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
