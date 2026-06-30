import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../data/onboarding_api.dart';

/// Confirmation that credentials were emailed to the resident's personal address.
class CredentialsSentPage extends StatefulWidget {
  final String destinationEmail;
  final String buildingName;
  final String apartmentCode;

  const CredentialsSentPage({
    super.key,
    required this.destinationEmail,
    required this.buildingName,
    required this.apartmentCode,
  });

  @override
  State<CredentialsSentPage> createState() => _CredentialsSentPageState();
}

class _CredentialsSentPageState extends State<CredentialsSentPage> {
  bool _resending = false;

  Future<void> _resend() async {
    setState(() => _resending = true);
    try {
      final result = await OnboardingApi.claimResident(
        buildingName: widget.buildingName,
        apartmentCode: widget.apartmentCode,
        personalEmail: widget.destinationEmail,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo reenviar. Inténtalo más tarde.')),
      );
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  void _goToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Success emblem
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.check, color: AppColors.primary, size: 44),
              ),
              const SizedBox(height: 32),
              const Text(
                '¡SOLICITUD PROCESADA!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFonts.headline,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Hemos verificado tus datos. Tus credenciales de acceso '
                  'han sido enviadas a tu correo electrónico. Por favor, revisa '
                  'tu bandeja de entrada.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Destination card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.mail_outline,
                          color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DESTINO',
                            style: TextStyle(
                              fontFamily: AppFonts.label,
                              fontSize: 11,
                              letterSpacing: 1.5,
                              color: Colors.white38,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.destinationEmail,
                            style: const TextStyle(
                              fontFamily: AppFonts.body,
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _goToLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.neutral,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Ir al Inicio de Sesión',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.body,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: _resending ? null : _resend,
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    children: [
                      const TextSpan(text: '¿No recibiste el correo? '),
                      TextSpan(
                        text: _resending ? 'Reenviando...' : 'Reenviar',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
