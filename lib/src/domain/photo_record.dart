enum UploadStatus { pending, uploaded }

extension UploadStatusX on UploadStatus {
  String get value {
    switch (this) {
      case UploadStatus.pending:
        return 'pending';
      case UploadStatus.uploaded:
        return 'uploaded';
    }
  }

  static UploadStatus fromValue(String raw) {
    switch (raw) {
      case 'uploaded':
        return UploadStatus.uploaded;
      case 'pending':
      default:
        return UploadStatus.pending;
    }
  }
}

class PhotoRecord {
  const PhotoRecord({
    required this.id,
    required this.filePath,
    required this.capturedAt,
    required this.latitude,
    required this.longitude,
    required this.uploadStatus,
    this.uploadedAt,
  });

  final String id;
  final String filePath;
  final DateTime capturedAt;
  final double latitude;
  final double longitude;
  final UploadStatus uploadStatus;
  final DateTime? uploadedAt;

  PhotoRecord copyWith({
    String? filePath,
    UploadStatus? uploadStatus,
    DateTime? uploadedAt,
  }) {
    return PhotoRecord(
      id: id,
      filePath: filePath ?? this.filePath,
      capturedAt: capturedAt,
      latitude: latitude,
      longitude: longitude,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'file_path': filePath,
      'captured_at': capturedAt.toUtc().toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'upload_status': uploadStatus.value,
      'uploaded_at': uploadedAt?.toUtc().toIso8601String(),
    };
  }

  factory PhotoRecord.fromMap(Map<String, Object?> map) {
    return PhotoRecord(
      id: map['id']! as String,
      filePath: map['file_path']! as String,
      capturedAt: DateTime.parse(map['captured_at']! as String),
      latitude: (map['latitude']! as num).toDouble(),
      longitude: (map['longitude']! as num).toDouble(),
      uploadStatus: UploadStatusX.fromValue(map['upload_status']! as String),
      uploadedAt: map['uploaded_at'] == null
          ? null
          : DateTime.parse(map['uploaded_at']! as String),
    );
  }
}
