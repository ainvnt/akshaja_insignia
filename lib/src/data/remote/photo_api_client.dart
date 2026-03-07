import 'dart:io';
import 'dart:typed_data';

import 'package:akshaja_insignia/src/domain/photo_record.dart';
import 'package:akshaja_insignia/src/services/s3_path_service.dart';
import 'package:flutter_avif/flutter_avif.dart';
import 'package:http/http.dart' as http;

class PhotoApiClient {
  const PhotoApiClient();

  Future<bool> uploadPhoto(PhotoRecord record) async {
    final sourceFile = File(record.filePath);
    if (!await sourceFile.exists()) {
      return false;
    }

    try {
      final jpegBytes = await sourceFile.readAsBytes();
      final avifBytes = await encodeAvif(
        Uint8List.fromList(jpegBytes),
        speed: 6,
        maxQuantizer: 38,
        minQuantizer: 22,
      );

      final uploadUri = Uri.parse(
        S3PathService.publicUrlForRecord(record),
      );

      final response = await http.put(
        uploadUri,
        headers: const <String, String>{
          'Content-Type': 'image/avif',
        },
        body: avifBytes,
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  Future<Uint8List?> downloadPhoto(PhotoRecord record) async {
    try {
      final downloadUri = Uri.parse(
        S3PathService.publicUrlForRecord(record),
      );
      final response = await http.get(downloadUri);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      return Uint8List.fromList(response.bodyBytes);
    } catch (_) {
      return null;
    }
  }

  void close() {}
}
