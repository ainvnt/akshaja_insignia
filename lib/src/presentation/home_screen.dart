import 'dart:async';
import 'dart:io';

import 'package:akshaja_insignia/src/domain/photo_record.dart';
import 'package:akshaja_insignia/src/presentation/camera_capture_screen.dart';
import 'package:akshaja_insignia/src/presentation/date_folder_gallery_screen.dart';
import 'package:akshaja_insignia/src/presentation/models/date_folder_group.dart';
import 'package:akshaja_insignia/src/presentation/widgets/date_folder_tile.dart';
import 'package:akshaja_insignia/src/presentation/widgets/home_summary_card.dart';
import 'package:akshaja_insignia/src/repositories/photo_repository.dart';
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

  void _openDateFolder(DateFolderGroup folder) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DateFolderGalleryScreen(
          dateKey: folder.key,
          photos: folder.photos,
          repository: widget.repository,
        ),
      ),
    );
  }

  Future<void> _deleteFolderLocalCopies(DateFolderGroup folder) async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Delete local files in ${folder.key.replaceAll('/', '-')}?',
            ),
            content: Text(
              'This will delete local copies for ${folder.photos.length} image(s). '
              'Cloud copies will remain available.',
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

    var deletedCount = 0;
    for (final photo in folder.photos) {
      final hasLocal = File(photo.filePath).existsSync();
      if (!hasLocal) {
        continue;
      }

      final deleted = await widget.repository.deleteLocalCopy(
        photo,
        onlyUploaded: false,
      );
      if (deleted) {
        deletedCount++;
      }
    }

    await _loadPhotos();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleted $deletedCount local file(s).')),
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

    final folders = _buildDateFolders();

    if (folders.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        children: const [
          HomeSummaryCard(totalPhotos: 0, uploadedPhotos: 0),
          SizedBox(height: 20),
          Center(child: Text('No date folders found.')),
        ],
      );
    }

    final uploadedCount = _photos
        .where((photo) => photo.uploadStatus == UploadStatus.uploaded)
        .length;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      itemCount: folders.length + 1,
      separatorBuilder: (_, index) =>
          index == 0 ? const SizedBox(height: 14) : const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return HomeSummaryCard(
            totalPhotos: _photos.length,
            uploadedPhotos: uploadedCount,
          );
        }

        final folder = folders[index - 1];
        return DateFolderTile(
          folder: folder,
          onDeleteLocal: () => _deleteFolderLocalCopies(folder),
          onOpen: () => _openDateFolder(folder),
        );
      },
    );
  }

  List<DateFolderGroup> _buildDateFolders() {
    final folderMap = <String, List<PhotoRecord>>{};
    for (final photo in _photos) {
      final key = _directoryLabel(photo);
      folderMap.putIfAbsent(key, () => <PhotoRecord>[]).add(photo);
    }

    final keys = folderMap.keys.toList()..sort((a, b) => b.compareTo(a));

    return keys
        .map(
          (key) => DateFolderGroup(
            key: key,
            photos: folderMap[key] ?? const <PhotoRecord>[],
          ),
        )
        .toList();
  }
}
