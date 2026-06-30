import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';

/// Builds an [ImageProvider] from a visitor photo string that may be either a
/// base64 data URL ("data:image/...;base64,XXXX") or a regular http(s) URL.
/// Returns null when there's no usable image, so callers can fall back to
/// initials or a placeholder icon.
ImageProvider? avatarImageProvider(String? photoUrl) {
  if (photoUrl == null || photoUrl.trim().isEmpty) return null;
  final url = photoUrl.trim();
  if (url.startsWith('data:')) {
    if (!url.contains(',')) return null;
    try {
      final Uint8List bytes = base64Decode(url.split(',').last);
      return MemoryImage(bytes);
    } catch (_) {
      return null;
    }
  }
  if (url.startsWith('http')) return NetworkImage(url);
  return null;
}
