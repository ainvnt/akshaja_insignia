import 'dart:async';
import 'dart:io';

import 'package:akshaja_insignia/src/data/local/photo_database.dart';
import 'package:akshaja_insignia/src/data/remote/photo_api_client.dart';
import 'package:akshaja_insignia/src/domain/photo_draft.dart';
import 'package:akshaja_insignia/src/domain/photo_record.dart';
import 'package:akshaja_insignia/src/services/network_service.dart';
import 'package:akshaja_insignia/src/services/photo_file_service.dart';
import 'package:uuid/uuid.dart';

class PhotoRepository {
  PhotoRepository({
    PhotoDatabase? database,
    PhotoApiClient? apiClient,
    NetworkService? networkService,
    PhotoFileService? photoFileService,
  })  : _database = database ?? PhotoDatabase(),
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

    _networkSubscription ??=
        _networkService.onStatusChanged.listen((bool isOnline) {
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
    final online = await _networkService.isOnline();
    if (!online || (!force && record.uploadStatus == UploadStatus.uploaded)) {
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
}
