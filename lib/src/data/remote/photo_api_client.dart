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

      // Try public-read ACL first. If bucket has ACLs disabled, retry without it.
      var response = await _putAvif(uploadUri, avifBytes, includePublicAcl: true);
      if ((response.statusCode == 400 || response.statusCode == 403) &&
          response.body.toLowerCase().contains('accesscontrollistnotsupported')) {
        response = await _putAvif(uploadUri, avifBytes, includePublicAcl: false);
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return false;
      }

      return _isPubliclyReadable(uploadUri);
    } catch (_) {
      return false;
    }
  }

  Future<http.Response> _putAvif(
    Uri uploadUri,
    Uint8List avifBytes, {
    required bool includePublicAcl,
  }) {
    final headers = <String, String>{
      'Content-Type': 'image/avif',
      if (includePublicAcl) 'x-amz-acl': 'public-read',
    };
    return http.put(
      uploadUri,
      headers: headers,
      body: avifBytes,
    );
  }

  Future<bool> _isPubliclyReadable(Uri uri) async {
    try {
      final response = await http.get(uri);
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  Future<Uint8List?> downloadPhoto(PhotoRecord record) async {
    try {
      final candidateUrls = S3PathService.publicUrlsForRecord(record);
      for (final url in candidateUrls) {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return Uint8List.fromList(response.bodyBytes);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  void close() {}
}
