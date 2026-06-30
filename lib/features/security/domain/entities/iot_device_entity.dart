class IoTDeviceEntity {
  final int id;
  final String deviceCode;
  final bool cameraEnabled;
  final bool microphoneEnabled;
  final String status;

  IoTDeviceEntity({
    required this.id,
    required this.deviceCode,
    required this.cameraEnabled,
    required this.microphoneEnabled,
    required this.status,
  });
}
