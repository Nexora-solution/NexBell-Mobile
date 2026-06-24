import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Minimal MJPEG live-video viewer.
///
/// Connects to the same multipart/x-mixed-replace stream the web app uses
/// (`GET /api/intercom/video-stream`), scans the incoming byte stream for
/// JPEG frame boundaries (SOI 0xFFD8 / EOI 0xFFD9), and repaints each
/// complete frame as it arrives — giving a live video feel without needing
/// a dedicated video-streaming package.
class MjpegView extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final Widget? placeholder;

  const MjpegView({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  @override
  State<MjpegView> createState() => _MjpegViewState();
}

class _MjpegViewState extends State<MjpegView> {
  Uint8List? _currentFrame;
  http.Client? _client;
  StreamSubscription<List<int>>? _subscription;
  final List<int> _buffer = [];
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    _client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(widget.url));
      final response = await _client!.send(request);
      _subscription = response.stream.listen(
        _onData,
        onError: (_) {
          if (mounted) setState(() => _hasError = true);
        },
        onDone: () {},
        cancelOnError: true,
      );
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  void _onData(List<int> chunk) {
    _buffer.addAll(chunk);

    while (true) {
      final start = _findMarker(0xFF, 0xD8, 0);
      if (start == -1) {
        // No frame start yet — avoid the buffer growing forever if the
        // stream sends non-JPEG noise before the first valid frame.
        if (_buffer.length > 2_000_000) _buffer.clear();
        break;
      }
      final end = _findMarker(0xFF, 0xD9, start + 2);
      if (end == -1) break; // frame not complete yet, wait for more data

      final frameBytes = Uint8List.fromList(_buffer.sublist(start, end + 2));
      _buffer.removeRange(0, end + 2);

      if (mounted) {
        setState(() {
          _currentFrame = frameBytes;
          _hasError = false;
        });
      }
    }
  }

  int _findMarker(int b1, int b2, int from) {
    for (int i = from; i < _buffer.length - 1; i++) {
      if (_buffer[i] == b1 && _buffer[i + 1] == b2) return i;
    }
    return -1;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _client?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError && _currentFrame == null) {
      return widget.placeholder ??
          const Center(child: Icon(Icons.videocam_off, color: Colors.white24, size: 48));
    }
    if (_currentFrame == null) {
      return widget.placeholder ??
          const Center(child: CircularProgressIndicator(color: Colors.tealAccent));
    }
    return Image.memory(
      _currentFrame!,
      fit: widget.fit,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) {
        return widget.placeholder ??
            const Center(child: Icon(Icons.videocam_off, color: Colors.white24, size: 48));
      },
    );
  }
}
