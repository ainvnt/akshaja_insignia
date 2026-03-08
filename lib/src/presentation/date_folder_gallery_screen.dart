import 'dart:io';
import 'dart:typed_data';

import 'package:akshaja_insignia/src/domain/photo_record.dart';
import 'package:akshaja_insignia/src/presentation/widgets/date_gallery_actions_bar.dart';
import 'package:akshaja_insignia/src/presentation/widgets/date_photo_grid_tile.dart';
import 'package:akshaja_insignia/src/repositories/photo_repository.dart';
import 'package:flutter/material.dart';

class DateFolderGalleryScreen extends StatefulWidget {
  const DateFolderGalleryScreen({
    super.key,
    required this.dateKey,
    required this.photos,
    required this.repository,
  });

  final String dateKey;
  final List<PhotoRecord> photos;
  final PhotoRepository repository;

  @override
  State<DateFolderGalleryScreen> createState() =>
      _DateFolderGalleryScreenState();
}

class _DateFolderGalleryScreenState extends State<DateFolderGalleryScreen> {
  final Map<String, Future<Uint8List?>> _thumbnailFutures =
      <String, Future<Uint8List?>>{};
  late List<PhotoRecord> _photos;
  final Set<String> _selectedIds = <String>{};

  bool get _selectionMode => _selectedIds.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _photos = List<PhotoRecord>.from(widget.photos);
  }

  Future<void> _deleteAllLocal() async {
    final confirm = await _confirmDelete(
      title: 'Delete all local copies?',
      message:
          'This removes local files for this date folder. Cloud copies remain.',
    );
    if (!confirm) {
      return;
    }

    var deletedCount = 0;
    for (final photo in _photos) {
      final localExists = File(photo.filePath).existsSync();
      if (!localExists) {
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

    if (!mounted) {
      return;
    }
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleted $deletedCount local file(s).')),
    );
  }

  Future<void> _deleteSelectedLocal() async {
    if (_selectedIds.isEmpty) {
      return;
    }

    final selectedPhotos = _photos
        .where((photo) => _selectedIds.contains(photo.id))
        .toList();
    final confirm = await _confirmDelete(
      title: 'Delete selected local copies?',
      message:
          'Delete local files for ${selectedPhotos.length} selected image(s)?',
    );
    if (!confirm) {
      return;
    }

    var deletedCount = 0;
    for (final photo in selectedPhotos) {
      final localExists = File(photo.filePath).existsSync();
      if (!localExists) {
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

    if (!mounted) {
      return;
    }
    setState(() {
      _selectedIds.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleted $deletedCount selected local file(s).')),
    );
  }

  Future<bool> _confirmDelete({
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
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
    );

    return result ?? false;
  }

  void _toggleSelection(PhotoRecord photo) {
    setState(() {
      if (_selectedIds.contains(photo.id)) {
        _selectedIds.remove(photo.id);
      } else {
        _selectedIds.add(photo.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = widget.dateKey.replaceAll('/', '-');
    final photos = _photos;

    return Scaffold(
      appBar: AppBar(
        title: Text(dateLabel),
        actions: [
          if (_selectionMode)
            IconButton(
              tooltip: 'Clear selection',
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _selectedIds.clear();
                });
              },
            ),
          if (_selectionMode)
            IconButton(
              tooltip: 'Delete selected local',
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteSelectedLocal,
            ),
        ],
      ),
      body: Column(
        children: [
          if (photos.isNotEmpty)
            DateGalleryActionsBar(
              selectionMode: _selectionMode,
              selectedCount: _selectedIds.length,
              onDeleteAllLocal: _deleteAllLocal,
            ),
          Expanded(
            child: photos.isEmpty
                ? const Center(
                    child: Text('No images found for the selected date.'),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                    itemCount: photos.length,
                    itemBuilder: (context, index) {
                      final photo = photos[index];
                      return DatePhotoGridTile(
                        photo: photo,
                        repository: widget.repository,
                        future: _thumbnailFutures.putIfAbsent(
                          photo.id,
                          () =>
                              widget.repository.fetchCloudThumbnailBytes(photo),
                        ),
                        selected: _selectedIds.contains(photo.id),
                        selectionMode: _selectionMode,
                        onToggleSelection: () => _toggleSelection(photo),
                        onAfterPreview: () => setState(() {}),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
