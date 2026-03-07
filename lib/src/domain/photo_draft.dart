class PhotoDraft {
  const PhotoDraft({
    required this.tempFilePath,
    required this.capturedAt,
    required this.latitude,
    required this.longitude,
  });

  final String tempFilePath;
  final DateTime capturedAt;
  final double latitude;
  final double longitude;
}
