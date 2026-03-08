import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:akshaja_insignia/src/domain/photo_record.dart';
import 'package:akshaja_insignia/src/presentation/camera_capture_screen.dart';
import 'package:akshaja_insignia/src/presentation/saved_photo_preview_screen.dart';
import 'package:akshaja_insignia/src/repositories/photo_repository.dart';
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
  final Map<String, Future<Uint8List?>> _thumbnailFutures =
      <String, Future<Uint8List?>>{};

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
      final imported = await widget.repository
          .syncFromCloudToLocalDateFolders();
      await _loadPhotos();
      if (!mounted) {
        return;
      }
      final message = imported > 0
          ? 'Sync complete. Imported $imported cloud item(s). Thumbnails load on demand.'
          : 'Sync complete.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sync failed: $error')));
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
        content: Text(
          uploaded
              ? (isReupload ? 'Photo reuploaded' : 'Photo uploaded')
              : 'Upload pending/offline',
        ),
      ),
    );
  }

  Future<void> _deleteLocalCopy(PhotoRecord photo) async {
    final localFile = File(photo.filePath);
    final hasLocalFile = localFile.existsSync();
    if (!hasLocalFile) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Local file already removed')),
      );
      return;
    }

    if (photo.uploadStatus != UploadStatus.uploaded) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload the photo first, then delete local copy'),
        ),
      );
      return;
    }

    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete local copy?'),
            content: const Text(
              'This will remove the file from device storage. '
              'Cloud copy will remain available.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete) {
      return;
    }

    final deleted = await widget.repository.deleteLocalCopy(photo);
    await _loadPhotos();

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deleted ? 'Local copy deleted' : 'Could not delete local copy',
        ),
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
        builder: (_) => SavedPhotoPreviewScreen(
          photo: photo,
          repository: widget.repository,
        ),
      ),
    );
  }

  Widget _buildThumbnail(PhotoRecord photo) {
    final localFile = File(photo.filePath);
    if (localFile.existsSync()) {
      if (photo.filePath.toLowerCase().endsWith('.avif')) {
        return AvifImage.file(
          localFile,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _brokenImagePlaceholder(),
        );
      }

      return Image.file(
        localFile,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _brokenImagePlaceholder(),
      );
    }

    if (photo.uploadStatus == UploadStatus.uploaded) {
      return FutureBuilder<Uint8List?>(
        future: _thumbnailFutures.putIfAbsent(
          photo.id,
          () => widget.repository.fetchCloudThumbnailBytes(photo),
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return _cloudLoadingPlaceholder();
          }

          final bytes = snapshot.data;
          if (bytes == null || bytes.isEmpty) {
            return _cloudOnlyPlaceholder();
          }

          return AvifImage.memory(
            bytes,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _cloudOnlyPlaceholder(),
          );
        },
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

  Widget _cloudOnlyPlaceholder() {
    return Container(
      width: 56,
      height: 56,
      color: Colors.blueGrey.shade100,
      alignment: Alignment.center,
      child: const Icon(Icons.cloud_done, color: Colors.green),
    );
  }

  Widget _cloudLoadingPlaceholder() {
    return Container(
      width: 56,
      height: 56,
      color: Colors.blueGrey.shade50,
      alignment: Alignment.center,
      child: SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.blueGrey.shade400,
        ),
      ),
    );
  }

  Widget _compactActionIcon({
    required IconData icon,
    required String tooltip,
    VoidCallback? onTap,
    Color? color,
  }) {
    final disabled = onTap == null;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 24,
          height: 24,
          child: Icon(icon, size: 18, color: disabled ? Colors.grey : color),
        ),
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_changesSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Akshaja Insignia'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _syncPendingPhotos,
            icon: const Icon(Icons.sync),
            tooltip: 'Sync pending uploads',
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.primary.withValues(alpha: 0.08),
              colorScheme.secondary.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCamera,
        tooltip: 'Open camera',
        icon: const Icon(Icons.camera_alt_rounded),
        label: const Text('Capture'),
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
              const Icon(Icons.error_outline, size: 34),
              const SizedBox(height: 10),
              Text(_errorText!, textAlign: TextAlign.center),
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
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        children: const [
          _HomeSummaryCard(totalPhotos: 0, uploadedPhotos: 0),
          SizedBox(height: 20),
          Center(child: Text('No photos captured yet.')),
        ],
      );
    }

    final uploadedCount = _photos
        .where((photo) => photo.uploadStatus == UploadStatus.uploaded)
        .length;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      itemCount: _photos.length + 1,
      separatorBuilder: (_, index) =>
          index == 0 ? const SizedBox(height: 14) : const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _HomeSummaryCard(
            totalPhotos: _photos.length,
            uploadedPhotos: uploadedCount,
          );
        }

        final photoIndex = index - 1;
        final photo = _photos[photoIndex];
        final capturedText = DateFormat(
          'dd MMM yyyy, hh:mm:ss a',
        ).format(photo.capturedAt.toLocal());
        final folderLabel = _directoryLabel(photo);
        final previousFolder = photoIndex == 0
            ? null
            : _directoryLabel(_photos[photoIndex - 1]);
        final showHeader = photoIndex == 0 || previousFolder != folderLabel;
        final hasLocalFile = File(photo.filePath).existsSync();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  folderLabel,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.45),
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => _openSavedPhotoPreview(photo),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: _buildThumbnail(photo),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              capturedText,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Lat ${photo.latitude.toStringAsFixed(6)}  |  '
                              'Lng ${photo.longitude.toStringAsFixed(6)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 7),
                            _statusPill(photo.uploadStatus),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 88,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _compactActionIcon(
                              onTap: () => _uploadSinglePhoto(photo),
                              icon: photo.uploadStatus == UploadStatus.uploaded
                                  ? Icons.cloud_done
                                  : Icons.cloud_upload,
                              color: photo.uploadStatus == UploadStatus.uploaded
                                  ? Colors.green
                                  : Colors.orange,
                              tooltip:
                                  photo.uploadStatus == UploadStatus.uploaded
                                  ? 'Reupload'
                                  : 'Upload',
                            ),
                            _compactActionIcon(
                              onTap: () => _openSavedPhotoPreview(photo),
                              icon: Icons.visibility,
                              tooltip: 'Preview',
                            ),
                            _compactActionIcon(
                              onTap:
                                  (hasLocalFile &&
                                      photo.uploadStatus ==
                                          UploadStatus.uploaded)
                                  ? () => _deleteLocalCopy(photo)
                                  : null,
                              icon: Icons.delete_outline,
                              tooltip: !hasLocalFile
                                  ? 'Local copy deleted'
                                  : (photo.uploadStatus == UploadStatus.uploaded
                                        ? 'Delete local copy'
                                        : 'Upload first to enable delete'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _statusPill(UploadStatus status) {
    final uploaded = status == UploadStatus.uploaded;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: uploaded
            ? Colors.green.withValues(alpha: 0.16)
            : Colors.orange.withValues(alpha: 0.16),
      ),
      child: Text(
        status.value.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 11,
          color: uploaded ? Colors.green.shade800 : Colors.orange.shade900,
        ),
      ),
    );
  }
}

class _HomeSummaryCard extends StatelessWidget {
  const _HomeSummaryCard({
    required this.totalPhotos,
    required this.uploadedPhotos,
  });

  final int totalPhotos;
  final int uploadedPhotos;

  @override
  Widget build(BuildContext context) {
    final pending = totalPhotos - uploadedPhotos;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.16),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Capture Overview',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    label: 'Total',
                    value: '$totalPhotos',
                    icon: Icons.photo_library_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryItem(
                    label: 'Uploaded',
                    value: '$uploadedPhotos',
                    icon: Icons.cloud_done_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryItem(
                    label: 'Pending',
                    value: '$pending',
                    icon: Icons.schedule_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
