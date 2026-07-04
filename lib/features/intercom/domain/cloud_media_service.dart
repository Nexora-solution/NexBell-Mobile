import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import 'package:http/http.dart' as http;

/// Service to handle Edge Media connections (Audio WS & Video MJPEG)
class CloudMediaService extends ChangeNotifier {
  final String deviceId;

  WebSocketChannel? _audioChannel;
  bool _isConnected = false;

  Uint8List? _latestFrame;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioRecorder _audioRecorder = AudioRecorder();

  bool _isLive = false;
  http.Client? _httpClient;
  StreamSubscription? _mjpegSub;
  StreamSubscription<Uint8List>? _micSub;

  CloudMediaService({required this.deviceId});

  bool get isConnected => _isConnected;
  Uint8List? get latestFrame => _latestFrame;

  void connectAudio(String wsUrl) {
    if (_isConnected) return;
    
    debugPrint('[CloudMedia] Connecting Audio to $wsUrl');
    _audioChannel = WebSocketChannel.connect(Uri.parse(wsUrl));

    _audioChannel!.stream.listen(
      (message) {
        if (!_isConnected) {
          _isConnected = true;
          notifyListeners();
        }
        
        if (message is Uint8List) {
          _playAudioChunk(message);
        } else if (message is List<int>) {
          _playAudioChunk(Uint8List.fromList(message));
        }
      },
      onDone: () {
        debugPrint('[CloudMedia] Audio WebSocket closed.');
        _isConnected = false;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('[CloudMedia] Audio WebSocket error: $error');
        _isConnected = false;
        notifyListeners();
      },
    );
  }

  void connectVideo(String url) async {
    if (_isLive) return;
    _isLive = true;
    _httpClient = http.Client();
    debugPrint('[CloudMedia] Connecting Video to $url');
    try {
      final request = http.Request('GET', Uri.parse(url));
      final response = await _httpClient!.send(request);
      
      List<int> buffer = [];
      _mjpegSub = response.stream.listen((chunk) {
        if (!_isLive) return;
        buffer.addAll(chunk);
        
        while (true) {
          int startIndex = -1;
          for (int i = 0; i < buffer.length - 1; i++) {
            if (buffer[i] == 0xFF && buffer[i+1] == 0xD8) {
              startIndex = i;
              break;
            }
          }
          
          if (startIndex == -1) {
            if (buffer.isNotEmpty) {
              buffer = [buffer.last];
            }
            break;
          }
          
          int endIndex = -1;
          for (int i = startIndex; i < buffer.length - 1; i++) {
            if (buffer[i] == 0xFF && buffer[i+1] == 0xD9) {
              endIndex = i + 1;
              break;
            }
          }
          
          if (endIndex != -1) {
            final frame = buffer.sublist(startIndex, endIndex + 1);
            _latestFrame = Uint8List.fromList(frame);
            notifyListeners();
            buffer = buffer.sublist(endIndex + 1);
          } else {
            buffer = buffer.sublist(startIndex);
            break;
          }
        }
      },
      onDone: () => debugPrint('[CloudMedia] Video Stream closed.'),
      onError: (e) => debugPrint('[CloudMedia] Video Stream error: $e')
      );
    } catch (e) {
      debugPrint('[CloudMedia] MJPEG Error: $e');
    }
  }

  void disconnect() {
    _audioChannel?.sink.close();
    _audioChannel = null;
    _isConnected = false;
    _latestFrame = null;
    
    _isLive = false;
    _mjpegSub?.cancel();
    _mjpegSub = null;
    _httpClient?.close();
    _httpClient = null;
    
    stopMic();
    
    notifyListeners();
  }

  Future<void> _playAudioChunk(Uint8List pcmBytes) async {
    try {
      final wavBytes = _addWavHeader(pcmBytes);
      await _audioPlayer.setAudioSource(MyCustomSource(wavBytes));
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('[CloudMedia] Error playing audio: $e');
    }
  }

  Uint8List _addWavHeader(Uint8List pcmBytes) {
    int byteRate = 16000 * 2 * 1;
    int totalAudioLen = pcmBytes.length;
    int totalDataLen = totalAudioLen + 36;
    
    var header = ByteData(44);
    header.setUint8(0, 0x52); header.setUint8(1, 0x49); header.setUint8(2, 0x46); header.setUint8(3, 0x46);
    header.setUint32(4, totalDataLen, Endian.little);
    header.setUint8(8, 0x57); header.setUint8(9, 0x41); header.setUint8(10, 0x56); header.setUint8(11, 0x45);
    header.setUint8(12, 0x66); header.setUint8(13, 0x6D); header.setUint8(14, 0x74); header.setUint8(15, 0x20);
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little);
    header.setUint16(22, 1, Endian.little);
    header.setUint32(24, 16000, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, 2, Endian.little);
    header.setUint16(34, 16, Endian.little);
    header.setUint8(36, 0x64); header.setUint8(37, 0x61); header.setUint8(38, 0x74); header.setUint8(39, 0x61);
    header.setUint32(40, totalAudioLen, Endian.little);

    var wavBytes = BytesBuilder();
    wavBytes.add(header.buffer.asUint8List());
    wavBytes.add(pcmBytes);
    return wavBytes.toBytes();
  }

  Future<void> startMic() async {
    if (await _audioRecorder.hasPermission()) {
      final stream = await _audioRecorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );

      _micSub = stream.listen((data) {
        if (_isConnected && _audioChannel != null) {
          _audioChannel!.sink.add(data);
        }
      });
    }
  }

  Future<void> stopMic() async {
    _micSub?.cancel();
    _micSub = null;
    await _audioRecorder.stop();
  }

  @override
  void dispose() {
    disconnect();
    _audioPlayer.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }
}

class MyCustomSource extends StreamAudioSource {
  final List<int> bytes;
  MyCustomSource(this.bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: 'audio/wav',
    );
  }
}
