// lib/common/config/api_config.dart
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

// IP de red local de la computadora que corre el backend. Solo aplica para
// un celular FÍSICO conectado a la misma red WiFi — actualízala si cambia
// tu red (revisa con `ipconfig`).
const String _lanBackendIp = '192.168.1.45';

String apiBase() {
  if (kIsWeb) return 'http://localhost:8080'; // Flutter Web
  switch (defaultTargetPlatform) {
    case TargetPlatform.android: return 'http://$_lanBackendIp:8080'; // Celular físico (mismo WiFi) o emulador
    case TargetPlatform.iOS:     return 'http://$_lanBackendIp:8080'; // Celular físico (mismo WiFi)
    default:                     return 'http://localhost:8080'; // Escritorio, etc.
  }
}