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
    final localCount = _photos
        .where((photo) => File(photo.filePath).existsSync())
        .length;
    if (localCount == 0) {
      final removeFromList = await _confirmDelete(
        title: 'No local files found',
        message:
            'This date folder appears cloud-only. Remove ${_photos.length} record(s) from this app list?',
      );
      if (removeFromList) {
        await widget.repository.deletePhotos(_photos, deleteLocalFiles: false);
        if (!mounted) {
          return;
        }
        setState(() {
          _photos = <PhotoRecord>[];
          _selectedIds.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Removed ${widget.photos.length} record(s) from app list.',
            ),
          ),
        );
      }
      return;
    }

    final confirm = await _confirmDelete(
      title: 'Delete all local copies?',
      message:
          'This removes $localCount local file(s) for this date folder. Cloud copies remain.',
    );
    if (!confirm) {
      return;
    }

    final deletedCount = await widget.repository.deleteLocalCopiesForDateFolder(
      widget.dateKey,
      _photos,
    );

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
    final selectedLocalCount = selectedPhotos
        .where((photo) => File(photo.filePath).existsSync())
        .length;
    if (selectedLocalCount == 0) {
      final removeFromList = await _confirmDelete(
        title: 'No local files in selection',
        message:
            'Selected items appear cloud-only. Remove ${selectedPhotos.length} record(s) from this app list?',
      );
      if (removeFromList) {
        await widget.repository.deletePhotos(
          selectedPhotos,
          deleteLocalFiles: false,
        );
        if (!mounted) {
          return;
        }
        final selectedIds = selectedPhotos.map((photo) => photo.id).toSet();
        setState(() {
          _photos.removeWhere((photo) => selectedIds.contains(photo.id));
          _selectedIds.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Removed ${selectedPhotos.length} record(s) from app list.',
            ),
          ),
        );
      }
      return;
    }

    final confirm = await _confirmDelete(
      title: 'Delete selected local copies?',
      message:
          'Delete $selectedLocalCount local file(s) in ${selectedPhotos.length} selected image(s)?',
    );
    if (!confirm) {
      return;
    }

    var deletedCount = 0;
    for (final photo in selectedPhotos) {
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
