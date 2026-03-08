import 'dart:io';
import 'dart:typed_data';

import 'package:akshaja_insignia/src/domain/photo_record.dart';
import 'package:akshaja_insignia/src/presentation/saved_photo_preview_screen.dart';
import 'package:akshaja_insignia/src/repositories/photo_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_avif/flutter_avif.dart';

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
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _deleteAllLocal,
                    icon: const Icon(Icons.delete_sweep_outlined),
                    label: const Text('Delete All Local'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectionMode
                          ? '${_selectedIds.length} selected'
                          : 'Long-press images to select',
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
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
                      return _PhotoGridTile(
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

class _PhotoGridTile extends StatelessWidget {
  const _PhotoGridTile({
    required this.photo,
    required this.repository,
    required this.future,
    required this.selected,
    required this.selectionMode,
    required this.onToggleSelection,
    required this.onAfterPreview,
  });

  final PhotoRecord photo;
  final PhotoRepository repository;
  final Future<Uint8List?> future;
  final bool selected;
  final bool selectionMode;
  final VoidCallback onToggleSelection;
  final VoidCallback onAfterPreview;

  @override
  Widget build(BuildContext context) {
    final localFile = File(photo.filePath);
    final hasLocal = localFile.existsSync();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          if (selectionMode) {
            onToggleSelection();
            return;
          }

          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  SavedPhotoPreviewScreen(photo: photo, repository: repository),
            ),
          );

          onAfterPreview();
        },
        onLongPress: onToggleSelection,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade200,
            border: selected
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                hasLocal
                    ? _localImage(localFile)
                    : FutureBuilder<Uint8List?>(
                        future: future,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState !=
                              ConnectionState.done) {
                            return const Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }

                          final bytes = snapshot.data;
                          if (bytes == null || bytes.isEmpty) {
                            return const Center(
                              child: Icon(Icons.broken_image_outlined),
                            );
                          }

                          return AvifImage.memory(
                            bytes,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Center(
                              child: Icon(Icons.broken_image_outlined),
                            ),
                          );
                        },
                      ),
                if (selected)
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _localImage(File localFile) {
    if (photo.filePath.toLowerCase().endsWith('.avif')) {
      return AvifImage.file(localFile, fit: BoxFit.cover);
    }
    return Image.file(localFile, fit: BoxFit.cover);
  }
}
