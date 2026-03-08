import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:akshaja_insignia/src/config/app_config.dart';
import 'package:akshaja_insignia/src/data/local/photo_database.dart';
import 'package:akshaja_insignia/src/data/remote/photo_api_client.dart';
import 'package:akshaja_insignia/src/domain/photo_draft.dart';
import 'package:akshaja_insignia/src/domain/photo_record.dart';
import 'package:akshaja_insignia/src/services/network_service.dart';
import 'package:akshaja_insignia/src/services/photo_file_service.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class PhotoRepository {
  PhotoRepository({
    PhotoDatabase? database,
    PhotoApiClient? apiClient,
    NetworkService? networkService,
    PhotoFileService? photoFileService,
  }) : _database = database ?? PhotoDatabase(),
       _apiClient = apiClient ?? PhotoApiClient(),
       _networkService = networkService ?? NetworkService(),
       _photoFileService = photoFileService ?? PhotoFileService();

  final PhotoDatabase _database;
  final PhotoApiClient _apiClient;
  final NetworkService _networkService;
  final PhotoFileService _photoFileService;
  final Uuid _uuid = const Uuid();
  final StreamController<void> _changesController =
      StreamController<void>.broadcast();

  StreamSubscription<bool>? _networkSubscription;
  bool _syncInProgress = false;

  Stream<void> get changes => _changesController.stream;

  Future<void> initialize() async {
    await _database.init();

    _networkSubscription ??= _networkService.onStatusChanged.listen((
      bool isOnline,
    ) {
      if (isOnline) {
        unawaited(syncPending());
      }
    });

    await syncPending();
  }

  Future<PhotoRecord> saveDraft(PhotoDraft draft) async {
    final photoId = 'photo_${_uuid.v4()}';
    final filePath = await _photoFileService.createStampedPhoto(
      sourcePath: draft.tempFilePath,
      photoId: photoId,
      capturedAt: draft.capturedAt,
      latitude: draft.latitude,
      longitude: draft.longitude,
    );

    final record = PhotoRecord(
      id: photoId,
      filePath: filePath,
      capturedAt: draft.capturedAt,
      latitude: draft.latitude,
      longitude: draft.longitude,
      uploadStatus: UploadStatus.pending,
    );

    await _database.insert(record);
    _notifyChanges();

    // Do not block the save flow with upload; start sync in background.
    unawaited(syncPending());
    return record;
  }

  Future<List<PhotoRecord>> getAllPhotos() {
    return _database.fetchAll();
  }

  Future<bool> uploadPhoto(PhotoRecord record, {bool force = false}) {
    return _tryUpload(record, force: force);
  }

  Future<bool> deleteLocalCopy(
    PhotoRecord record, {
    bool onlyUploaded = true,
  }) async {
    if (onlyUploaded && record.uploadStatus != UploadStatus.uploaded) {
      return false;
    }

    final file = File(record.filePath);
    if (await file.exists()) {
      await file.delete();
    }

    _notifyChanges();
    return true;
  }

  Future<PhotoRecord?> restoreLocalCopyFromCloud(PhotoRecord record) async {
    if (record.uploadStatus != UploadStatus.uploaded) {
      return null;
    }

    final avifBytes = await _apiClient.downloadPhoto(record);
    if (avifBytes == null) {
      return null;
    }

    final restorePath = p.setExtension(record.filePath, '.avif');
    final targetFile = File(restorePath);
    await targetFile.parent.create(recursive: true);
    await targetFile.writeAsBytes(avifBytes, flush: true);

    await _database.updateFilePath(photoId: record.id, filePath: restorePath);

    final updated = record.copyWith(filePath: restorePath);
    _notifyChanges();
    return updated;
  }

  Future<Uint8List?> fetchCloudPhotoBytes(PhotoRecord record) {
    return _apiClient.downloadPhoto(record);
  }

  Future<Uint8List?> fetchCloudThumbnailBytes(PhotoRecord record) {
    return _apiClient.downloadPhoto(record);
  }

  Future<int> syncFromCloudToLocalDateFolders() async {
    final objectKeys = await _apiClient.listRemoteObjectKeys();
    if (objectKeys.isEmpty) {
      await clearAllLocalData();
      return 0;
    }

    final existingRecords = await _database.fetchAll();
    final existingIds = existingRecords.map((e) => e.id).toSet();
    final docsDir = await getApplicationDocumentsDirectory();

    var importedCount = 0;
    for (final objectKey in objectKeys) {
      final metadata = _parseS3ObjectKey(objectKey);
      if (metadata == null) {
        continue;
      }

      final photoId = metadata.photoId;
      if (existingIds.contains(photoId)) {
        continue;
      }

      final dayDirectoryPath = p.join(
        docsDir.path,
        'photos',
        metadata.year,
        metadata.month,
        metadata.day,
      );
      await Directory(dayDirectoryPath).create(recursive: true);

      final localPath = p.join(dayDirectoryPath, '$photoId.avif');

      final capturedAt = DateTime.utc(
        int.parse(metadata.year),
        int.parse(metadata.month),
        int.parse(metadata.day),
      );

      final record = PhotoRecord(
        id: photoId,
        filePath: localPath,
        capturedAt: capturedAt,
        latitude: 0,
        longitude: 0,
        uploadStatus: UploadStatus.uploaded,
        uploadedAt: DateTime.now().toUtc(),
      );

      await _database.insert(record);
      existingIds.add(photoId);
      importedCount++;
    }

    if (importedCount > 0) {
      _notifyChanges();
    }

    return importedCount;
  }

  Future<void> clearAllLocalData() async {
    final existingRecords = await _database.fetchAll();
    for (final record in existingRecords) {
      final file = File(record.filePath);
      if (await file.exists()) {
        await file.delete();
      }
    }

    final docsDir = await getApplicationDocumentsDirectory();
    final photosRoot = Directory(p.join(docsDir.path, 'photos'));
    if (await photosRoot.exists()) {
      await photosRoot.delete(recursive: true);
    }

    await _database.clearAll();
    _notifyChanges();
  }

  Future<int> deletePhotos(
    List<PhotoRecord> records, {
    bool deleteLocalFiles = true,
  }) async {
    if (records.isEmpty) {
      return 0;
    }

    var deletedLocalCount = 0;
    if (deleteLocalFiles) {
      for (final record in records) {
        final file = File(record.filePath);
        if (await file.exists()) {
          await file.delete();
          deletedLocalCount++;
        }
      }
    }

    await _database.deleteByIds(records.map((e) => e.id).toList());
    _notifyChanges();
    return deletedLocalCount;
  }

  Future<void> syncPending() async {
    if (_syncInProgress) {
      return;
    }

    final online = await _networkService.isOnline();
    if (!online) {
      return;
    }

    _syncInProgress = true;
    try {
      final pending = await _database.fetchPending();
      for (final record in pending) {
        await _tryUpload(record);
      }
    } finally {
      _syncInProgress = false;
    }
  }

  Future<bool> _tryUpload(PhotoRecord record, {bool force = false}) async {
    if (!force) {
      final online = await _networkService.isOnline();
      if (!online) {
        return false;
      }
    }

    if (!force && record.uploadStatus == UploadStatus.uploaded) {
      return false;
    }

    final uploaded = await _apiClient.uploadPhoto(record);
    if (!uploaded) {
      return false;
    }

    await _database.updateUploadState(
      photoId: record.id,
      status: UploadStatus.uploaded,
      uploadedAt: DateTime.now().toUtc(),
    );
    _notifyChanges();
    return true;
  }

  void _notifyChanges() {
    if (!_changesController.isClosed) {
      _changesController.add(null);
    }
  }

  Future<void> dispose() async {
    await _networkSubscription?.cancel();
    await _changesController.close();
    await _database.close();
    _apiClient.close();
  }

  _S3KeyMetadata? _parseS3ObjectKey(String objectKey) {
    final normalizedPrefix = AppConfig.s3Prefix.replaceAll(
      RegExp(r'^/+|/+$'),
      '',
    );
    final prefixWithSlash = '$normalizedPrefix/';
    if (!objectKey.startsWith(prefixWithSlash)) {
      return null;
    }

    final remainder = objectKey.substring(prefixWithSlash.length);
    final parts = remainder.split('/');
    if (parts.length < 4) {
      return null;
    }

    final year = parts[0];
    final month = parts[1];
    final day = parts[2];
    final fileName = parts[3];
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex <= 0) {
      return null;
    }

    final photoId = fileName.substring(0, dotIndex);
    if (photoId.isEmpty) {
      return null;
    }

    return _S3KeyMetadata(year: year, month: month, day: day, photoId: photoId);
  }
}

class _S3KeyMetadata {
  const _S3KeyMetadata({
    required this.year,
    required this.month,
    required this.day,
    required this.photoId,
  });

  final String year;
  final String month;
  final String day;
  final String photoId;
}
