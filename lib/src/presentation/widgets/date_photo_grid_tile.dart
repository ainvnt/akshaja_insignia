import 'dart:io';
import 'dart:typed_data';

import 'package:akshaja_insignia/src/domain/photo_record.dart';
import 'package:akshaja_insignia/src/presentation/saved_photo_preview_screen.dart';
import 'package:akshaja_insignia/src/repositories/photo_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_avif/flutter_avif.dart';

class DatePhotoGridTile extends StatelessWidget {
  const DatePhotoGridTile({
    super.key,
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
