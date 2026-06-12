// lib/common/config/api_config.dart
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

String apiBase() {
  if (kIsWeb) return 'http://localhost:8080'; // Flutter Web
  switch (defaultTargetPlatform) {
    case TargetPlatform.android: return 'http://10.0.2.2:8080'; // Emulador Android
    case TargetPlatform.iOS:     return 'http://localhost:8080'; // Simulador iOS
    default:                     return 'http://localhost:8080'; // Escritorio, etc.
  }
}