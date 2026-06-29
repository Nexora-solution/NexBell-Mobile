import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';
import '../../../../common/utils/api_client.dart';
import '../../../../features/main/main_screen.dart';
import 'landing_page.dart';

/// Brand splash shown on app launch. After a short beat it routes to the home
/// dashboard if there is a saved session, otherwise to the landing screen.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  // Brighter aquamarine for the splash backdrop; same brand hue as the web teal.
  static const Color _splashBg = Color(0xFF7FE3DB);

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    final token = await ApiClient.getToken();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => token != null && token.isNotEmpty
            ? const MainScreen()
            : const LandingPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _splashBg,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Main emblem + wordmark, dead-center of the screen on both axes.
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Emblem: ring with a dark disc holding a white shield.
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 3),
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield, color: _splashBg, size: 30),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'NEXORA',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppFonts.headline,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'N E X B E L L',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.label,
                    fontSize: 12,
                    color: Colors.black54,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),
          // Footer pinned to the bottom, independent of the centered block above.
          Positioned(
            left: 0,
            right: 0,
            bottom: 36,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(width: 28, height: 2, color: Colors.black26),
                const SizedBox(height: 16),
                const Text(
                  'POWERING SMART SECURITY',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.label,
                    fontSize: 10,
                    color: Colors.black54,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
