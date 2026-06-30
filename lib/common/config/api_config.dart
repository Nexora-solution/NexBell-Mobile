// lib/common/config/api_config.dart
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

const String _productionBackend = 'https://nexbell-webservices.onrender.com';

// Para desarrollo local, cambia _useProduction a false y ajusta _lanBackendIp.
const bool _useProduction = true;
const String _lanBackendIp = '192.168.1.100';

String apiBase() {
  if (_useProduction) return _productionBackend;
  if (kIsWeb) return 'http://localhost:8080';
  switch (defaultTargetPlatform) {
    case TargetPlatform.android: return 'http://$_lanBackendIp:8080';
    case TargetPlatform.iOS:     return 'http://$_lanBackendIp:8080';
    default:                     return 'http://localhost:8080';
  }
}

String edgeBase() {
  if (kIsWeb) return 'http://localhost:3100';
  switch (defaultTargetPlatform) {
    case TargetPlatform.android: return 'http://$_lanBackendIp:3100';
    case TargetPlatform.iOS:     return 'http://$_lanBackendIp:3100';
    default:                     return 'http://localhost:3100';
  }
}
