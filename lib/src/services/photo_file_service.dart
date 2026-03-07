import 'dart:io';

import 'package:akshaja_insignia/src/services/watermark_service.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PhotoFileService {
  PhotoFileService({WatermarkService? watermarkService})
      : _watermarkService = watermarkService ?? const WatermarkService();

  final WatermarkService _watermarkService;

  Future<String> createStampedPhoto({
    required String sourcePath,
    required String photoId,
    required DateTime capturedAt,
    required double latitude,
    required double longitude,
  }) async {
    final sourceFile = File(sourcePath);
    final sourceBytes = await sourceFile.readAsBytes();

    final stampedBytes = _watermarkService.stampPhoto(
      sourceBytes: sourceBytes,
      capturedAt: capturedAt,
      latitude: latitude,
      longitude: longitude,
    );

    final docsDir = await getApplicationDocumentsDirectory();
    final localCapturedAt = capturedAt.toLocal();
    final year = DateFormat('yyyy').format(localCapturedAt);
    final month = DateFormat('MM').format(localCapturedAt);
    final day = DateFormat('dd').format(localCapturedAt);

    final photosDir = Directory(
      p.join(docsDir.path, 'photos', year, month, day),
    );
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    final outputPath = p.join(photosDir.path, '$photoId.jpg');
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(stampedBytes, flush: true);
    return outputPath;
  }
}
