// lib/common/config/api_config.dart
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

const String _productionBackend = 'https://nexbell-webservices.onrender.com';

// Para desarrollo local, cambia _useProduction a false y ajusta _lanBackendIp.
const bool _useProduction = false;
const String _lanBackendIp = '192.168.0.207'; // Use 10.0.2.2 for Android Emulator (change to e.g. 192.168.0.207 for physical devices)

String apiBase() {
  if (_useProduction) return _productionBackend;
  if (kIsWeb) return 'http://localhost:8080';
  switch (defaultTargetPlatform) {
    case TargetPlatform.android: return 'http://$_lanBackendIp:8080';
    case TargetPlatform.iOS:     return 'http://$_lanBackendIp:8080';
    default:                     return 'http://localhost:8080';
  }
}

// El video en vivo (MJPEG) lo sirve el Edge Service en la LAN, junto al ESP32
// — NO el backend (la web ya consume el video desde aquí). El firmware envía
// los frames por TCP al Edge y el Edge los expone en /video-stream:3100.
String edgeBase() {
  if (kIsWeb) return 'http://localhost:3100'; // Flutter Web (misma máquina que el Edge)
  switch (defaultTargetPlatform) {
    case TargetPlatform.android: return 'http://$_lanBackendIp:3100'; // Celular físico (mismo WiFi) o emulador
    case TargetPlatform.iOS:     return 'http://$_lanBackendIp:3100'; // Celular físico (mismo WiFi)
    default:                     return 'http://localhost:3100'; // Escritorio, etc.
  }
}