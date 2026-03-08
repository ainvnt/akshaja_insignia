import 'dart:io';

import 'package:akshaja_insignia/src/domain/photo_record.dart';
import 'package:akshaja_insignia/src/repositories/photo_repository.dart';
import 'package:akshaja_insignia/src/services/s3_path_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_avif/flutter_avif.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class SavedPhotoPreviewScreen extends StatefulWidget {
  const SavedPhotoPreviewScreen({
    super.key,
    required this.photo,
    required this.repository,
  });

  final PhotoRecord photo;
  final PhotoRepository repository;

  @override
  State<SavedPhotoPreviewScreen> createState() => _SavedPhotoPreviewScreenState();
}

class _SavedPhotoPreviewScreenState extends State<SavedPhotoPreviewScreen> {
  late PhotoRecord _photo;
  Future<String?>? _cloudUrlFuture;
  bool _restoring = false;

  @override
  void initState() {
    super.initState();
    _photo = widget.photo;
    _cloudUrlFuture = _resolveAccessibleCloudUrl();
  }

  Future<String?> _resolveAccessibleCloudUrl() async {
    final urls = S3PathService.publicUrlsForRecord(_photo);
    for (final url in urls) {
      try {
        final response = await http.get(
          Uri.parse(url),
          headers: const <String, String>{
            'Range': 'bytes=0-1023',
          },
        );

        if (response.statusCode == 200 || response.statusCode == 206) {
          return url;
        }
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  Future<void> _storeLocally() async {
    setState(() {
      _restoring = true;
    });

    try {
      final restored = await widget.repository.restoreLocalCopyFromCloud(_photo);
      if (!mounted) {
        return;
      }

      if (restored == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not store local copy')),
        );
        return;
      }

      setState(() {
        _photo = restored;
        _cloudUrlFuture = _resolveAccessibleCloudUrl();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Local copy stored')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _restoring = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final captured = DateFormat('dd-MM-yyyy HH:mm:ss')
        .format(_photo.capturedAt.toLocal());
    final localFile = File(_photo.filePath);
    final hasLocalFile = localFile.existsSync();
    final isLocalAvif = _photo.filePath.toLowerCase().endsWith('.avif');
    final canStoreLocally =
        !hasLocalFile && _photo.uploadStatus == UploadStatus.uploaded;

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Photo Preview')),
      body: Column(
        children: [
          Expanded(
            child: hasLocalFile
                ? (isLocalAvif
                    ? AvifImage.file(
                        localFile,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      )
                    : Image.file(
                        localFile,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ))
                : FutureBuilder<String?>(
                    future: _cloudUrlFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final resolvedUrl = snapshot.data;
                      if (resolvedUrl == null || resolvedUrl.isEmpty) {
                        return const Center(
                          child: Text(
                            'Cloud image not accessible. '
                            'Please verify S3 read access.',
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      return AvifImage.network(
                        resolvedUrl,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Center(
                          child: Text('Image not available.'),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Captured: $captured'),
                Text('Lat: ${_photo.latitude.toStringAsFixed(6)}'),
                Text('Lng: ${_photo.longitude.toStringAsFixed(6)}'),
                Text('Upload: ${_photo.uploadStatus.value}'),
                if (canStoreLocally) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _restoring ? null : _storeLocally,
                    icon: _restoring
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download),
                    label: const Text('Store locally'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
