import 'dart:io';

import 'package:akshaja_insignia/src/domain/photo_record.dart';
import 'package:akshaja_insignia/src/services/s3_path_service.dart';
import 'package:flutter_avif/flutter_avif.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SavedPhotoPreviewScreen extends StatelessWidget {
  const SavedPhotoPreviewScreen({super.key, required this.photo});

  final PhotoRecord photo;

  @override
  Widget build(BuildContext context) {
    final captured = DateFormat('dd-MM-yyyy HH:mm:ss')
        .format(photo.capturedAt.toLocal());
    final localFile = File(photo.filePath);
    final hasLocalFile = localFile.existsSync();
    final s3Url = S3PathService.publicUrlForRecord(photo);

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Photo Preview')),
      body: Column(
        children: [
          Expanded(
            child: hasLocalFile
                ? Image.file(
                    localFile,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  )
                : AvifImage.network(
                    s3Url,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Center(
                      child: Text('Image not available.'),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Captured: $captured'),
                Text('Lat: ${photo.latitude.toStringAsFixed(6)}'),
                Text('Lng: ${photo.longitude.toStringAsFixed(6)}'),
                Text('Upload: ${photo.uploadStatus.value}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
