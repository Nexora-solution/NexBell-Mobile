import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';
import '../../../auth/presentation/pages/login_page.dart';
import 'request_credentials_page.dart';

/// First interactive screen: pick between signing in or requesting credentials.
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Full-screen building photo background.
          Positioned.fill(
            child: Image.asset(
              'assets/images/edificio_digitalizado.png',
              fit: BoxFit.cover,
            ),
          ),
          // Dark scrim so the text/buttons stay readable over the photo.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.55),
                    Colors.black.withOpacity(0.35),
                    Colors.black.withOpacity(0.88),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  // Wordmark
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shield, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Nexora',
                        style: TextStyle(
                          fontFamily: AppFonts.headline,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(flex: 2),
                  // Bell emblem
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.notifications_active,
                        color: AppColors.primary, size: 40),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'TU EDIFICIO, DIGITALIZADO',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppFonts.headline,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Control de acceso inteligente y seguridad\nde vanguardia para tu hogar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 14,
                      color: Colors.white60,
                      height: 1.4,
                    ),
                  ),
                  const Spacer(flex: 3),
                  // Primary: sign in
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.neutral,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.body,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Secondary: request credentials
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RequestCredentialsPage()),
                    ),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        children: [
                          TextSpan(text: '¿Eres residente? '),
                          TextSpan(
                            text: 'Solicita tus credenciales',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        '¿Necesitas ayuda?',
                        style: TextStyle(
                          fontFamily: AppFonts.label,
                          fontSize: 12,
                          color: Colors.white38,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.help_outline, color: Colors.white38, size: 14),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
