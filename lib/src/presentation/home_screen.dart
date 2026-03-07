import 'dart:async';
import 'dart:io';

import 'package:akshaja_insignia/src/domain/photo_record.dart';
import 'package:akshaja_insignia/src/presentation/camera_capture_screen.dart';
import 'package:akshaja_insignia/src/presentation/saved_photo_preview_screen.dart';
import 'package:akshaja_insignia/src/repositories/photo_repository.dart';
import 'package:akshaja_insignia/src/services/s3_path_service.dart';
import 'package:flutter_avif/flutter_avif.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repository});

  final PhotoRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription<void>? _changesSubscription;

  bool _loading = true;
  String? _errorText;
  List<PhotoRecord> _photos = const <PhotoRecord>[];

  @override
  void initState() {
    super.initState();
    _changesSubscription = widget.repository.changes.listen((_) {
      unawaited(_loadPhotos());
    });
    unawaited(_initializeScreen());
  }

  Future<void> _initializeScreen() async {
    try {
      await widget.repository.syncPending();
      await _loadPhotos();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorText = 'Failed to load photos: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadPhotos() async {
    final records = await widget.repository.getAllPhotos();
    final sorted = <PhotoRecord>[...records]
      ..sort((a, b) {
        final folderA = _dateFolderKey(a.filePath);
        final folderB = _dateFolderKey(b.filePath);
        final folderCompare = folderB.compareTo(folderA);
        if (folderCompare != 0) {
          return folderCompare;
        }
        return b.capturedAt.compareTo(a.capturedAt);
      });

    if (!mounted) {
      return;
    }
    setState(() {
      _photos = sorted;
    });
  }

  String _dateFolderKey(String filePath) {
    final normalized = filePath.replaceAll('\\', '/');
    final marker = '/photos/';
    final markerIndex = normalized.lastIndexOf(marker);

    if (markerIndex == -1) {
      return '';
    }

    final afterPhotos = normalized.substring(markerIndex + marker.length);
    final parts = afterPhotos.split('/');
    if (parts.length < 4) {
      return '';
    }

    return '${parts[0]}/${parts[1]}/${parts[2]}';
  }

  String _directoryLabel(PhotoRecord photo) {
    final key = _dateFolderKey(photo.filePath);
    if (key.isNotEmpty) {
      return key;
    }
    return DateFormat('yyyy/MM/dd').format(photo.capturedAt.toLocal());
  }

  Future<void> _syncPendingPhotos() async {
    try {
      await widget.repository.syncPending();
      await _loadPhotos();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sync complete')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync failed: $error')),
      );
    }
  }

  Future<void> _uploadSinglePhoto(PhotoRecord photo) async {
    final isReupload = photo.uploadStatus == UploadStatus.uploaded;
    final uploaded = await widget.repository.uploadPhoto(photo, force: true);
    await _loadPhotos();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(uploaded
            ? (isReupload ? 'Photo reuploaded' : 'Photo uploaded')
            : 'Upload pending/offline'),
      ),
    );
  }

  Future<void> _openCamera() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => CameraCaptureScreen(repository: widget.repository),
      ),
    );

    if (saved == true) {
      await _loadPhotos();
    }
  }

  void _openSavedPhotoPreview(PhotoRecord photo) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SavedPhotoPreviewScreen(photo: photo),
      ),
    );
  }

  Widget _buildThumbnail(PhotoRecord photo) {
    final localFile = File(photo.filePath);
    if (localFile.existsSync()) {
      return Image.file(
        localFile,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _brokenImagePlaceholder(),
      );
    }

    if (photo.uploadStatus == UploadStatus.uploaded) {
      return AvifImage.network(
        S3PathService.publicUrlForRecord(photo),
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _brokenImagePlaceholder(),
      );
    }

    return _brokenImagePlaceholder();
  }

  Widget _brokenImagePlaceholder() {
    return Container(
      width: 56,
      height: 56,
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image),
    );
  }

  @override
  void dispose() {
    unawaited(_changesSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geo Camera'),
        actions: [
          IconButton(
            onPressed: _syncPendingPhotos,
            icon: const Icon(Icons.sync),
            tooltip: 'Sync pending uploads',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCamera,
        tooltip: 'Open camera',
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorText != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_errorText!),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _loading = true;
                    _errorText = null;
                  });
                  unawaited(_initializeScreen());
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_photos.isEmpty) {
      return const Center(child: Text('No photos captured yet.'));
    }

    return ListView.separated(
      itemCount: _photos.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final photo = _photos[index];
        final capturedText =
            DateFormat('dd-MM-yyyy HH:mm:ss').format(photo.capturedAt.toLocal());
        final folderLabel = _directoryLabel(photo);
        final previousFolder =
            index == 0 ? null : _directoryLabel(_photos[index - 1]);
        final showHeader = index == 0 || previousFolder != folderLabel;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader)
              Container(
                width: double.infinity,
                color: Colors.blueGrey.withValues(alpha: 0.08),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  'Directory: $folderLabel',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildThumbnail(photo),
              ),
              title: Text(capturedText),
              subtitle: Text(
                'Folder: $folderLabel\n'
                'Lat ${photo.latitude.toStringAsFixed(6)} | '
                'Lng ${photo.longitude.toStringAsFixed(6)}',
              ),
              isThreeLine: true,
              trailing: SizedBox(
                width: 92,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _uploadSinglePhoto(photo),
                      icon: Icon(
                        photo.uploadStatus == UploadStatus.uploaded
                            ? Icons.cloud_done
                            : Icons.cloud_upload,
                        size: 20,
                        color: photo.uploadStatus == UploadStatus.uploaded
                            ? Colors.green
                            : Colors.orange,
                      ),
                      tooltip: photo.uploadStatus == UploadStatus.uploaded
                          ? 'Reupload'
                          : 'Upload',
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints.tightFor(
                        width: 28,
                        height: 28,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _openSavedPhotoPreview(photo),
                      icon: const Icon(Icons.visibility, size: 20),
                      tooltip: 'Preview',
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints.tightFor(
                        width: 28,
                        height: 28,
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () => _openSavedPhotoPreview(photo),
            ),
          ],
        );
      },
    );
  }
}
