import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:akshaja_insignia/src/config/app_config.dart';
import 'package:akshaja_insignia/src/domain/photo_record.dart';
import 'package:akshaja_insignia/src/services/aws_sig_v4_signer.dart';
import 'package:akshaja_insignia/src/services/s3_path_service.dart';
import 'package:flutter_avif/flutter_avif.dart';
import 'package:http/http.dart' as http;

class PhotoApiClient {
  const PhotoApiClient();

  static final RegExp _keyTagRegex = RegExp(r'<Key>([^<]+)</Key>');
  static final RegExp _nextTokenRegex = RegExp(
    r'<NextContinuationToken>([^<]+)</NextContinuationToken>',
  );

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

      final uploadUri = Uri.parse(S3PathService.publicUrlForRecord(record));
      final objectKey = S3PathService.objectKeyForRecord(record);

      late final http.Response response;
      var usedPresignedUrl = false;
      if (AppConfig.hasPresignApi) {
        final presigned = await _requestPresignedUpload(
          objectKey: objectKey,
          contentType: 'image/avif',
        );
        if (presigned == null) {
          return false;
        }
        usedPresignedUrl = true;
        response = await http.put(
          presigned.uploadUri,
          headers: presigned.headers,
          body: avifBytes,
        );
      } else if (AppConfig.hasAwsCredentials) {
        response = await _putAvifSigned(uploadUri, avifBytes);
      } else {
        // Try public-read ACL first. If bucket has ACLs disabled, retry without it.
        var publicResponse = await _putAvif(
          uploadUri,
          avifBytes,
          includePublicAcl: true,
        );
        if ((publicResponse.statusCode == 400 ||
                publicResponse.statusCode == 403) &&
            publicResponse.body.toLowerCase().contains(
              'accesscontrollistnotsupported',
            )) {
          publicResponse = await _putAvif(
            uploadUri,
            avifBytes,
            includePublicAcl: false,
          );
        }
        response = publicResponse;
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return false;
      }

      if (usedPresignedUrl || AppConfig.hasAwsCredentials) {
        // Successful authenticated PUT is enough to mark upload success.
        return true;
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
    return http.put(uploadUri, headers: headers, body: avifBytes);
  }

  Future<http.Response> _putAvifSigned(Uri uploadUri, Uint8List avifBytes) {
    final headers = AwsSigV4Signer.signedPutHeaders(uploadUri, avifBytes);
    return http.put(uploadUri, headers: headers, body: avifBytes);
  }

  Future<_PresignedUpload?> _requestPresignedUpload({
    required String objectKey,
    required String contentType,
  }) async {
    try {
      final endpoint = Uri.parse(AppConfig.s3PresignApiUrl.trim());
      final requestHeaders = <String, String>{
        'Content-Type': 'application/json',
        if (AppConfig.s3PresignApiToken.trim().isNotEmpty)
          'Authorization': 'Bearer ${AppConfig.s3PresignApiToken.trim()}',
      };

      final response = await http.post(
        endpoint,
        headers: requestHeaders,
        body: jsonEncode(<String, String>{
          'bucket': AppConfig.s3Bucket,
          'objectKey': objectKey,
          'contentType': contentType,
          'method': 'PUT',
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final uploadUrl = (decoded['uploadUrl'] ?? decoded['url'])?.toString();
      if (uploadUrl == null || uploadUrl.isEmpty) {
        return null;
      }

      final dynamic headersRaw = decoded['headers'];
      final uploadHeaders = <String, String>{'Content-Type': contentType};
      if (headersRaw is Map) {
        for (final entry in headersRaw.entries) {
          uploadHeaders[entry.key.toString()] = entry.value.toString();
        }
      }

      return _PresignedUpload(
        uploadUri: Uri.parse(uploadUrl),
        headers: uploadHeaders,
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> _isPubliclyReadable(Uri uri) async {
    try {
      final response = AppConfig.hasAwsCredentials
          ? await http.get(uri, headers: AwsSigV4Signer.signedGetHeaders(uri))
          : await http.get(uri);
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  Future<Uint8List?> downloadPhoto(PhotoRecord record) async {
    try {
      final candidateUrls = S3PathService.publicUrlsForRecord(record);
      for (final url in candidateUrls) {
        final uri = Uri.parse(url);
        final response = AppConfig.hasAwsCredentials
            ? await http.get(uri, headers: AwsSigV4Signer.signedGetHeaders(uri))
            : await http.get(uri);
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return Uint8List.fromList(response.bodyBytes);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<String>> listRemoteObjectKeys() async {
    if (!AppConfig.hasAwsCredentials) {
      return const <String>[];
    }

    final allKeys = <String>[];
    String? continuationToken;
    final normalizedPrefix =
        '${AppConfig.s3Prefix.replaceAll(RegExp(r'^/+|/+$'), '')}/';

    while (true) {
      final listUri = _buildListUri(
        prefix: normalizedPrefix,
        continuationToken: continuationToken,
      );

      final response = await http.get(
        listUri,
        headers: AwsSigV4Signer.signedGetHeaders(listUri),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return const <String>[];
      }

      final responseBody = response.body;
      for (final match in _keyTagRegex.allMatches(responseBody)) {
        final rawKey = match.group(1);
        if (rawKey == null || rawKey.isEmpty) {
          continue;
        }

        final key = _xmlUnescape(rawKey);
        if (!key.startsWith(normalizedPrefix) || key.endsWith('/')) {
          continue;
        }
        allKeys.add(key);
      }

      final nextTokenMatch = _nextTokenRegex.firstMatch(responseBody);
      final nextToken = nextTokenMatch?.group(1);
      if (nextToken == null || nextToken.isEmpty) {
        break;
      }
      continuationToken = _xmlUnescape(nextToken);
    }

    return allKeys.toSet().toList()..sort();
  }

  Future<Uint8List?> downloadPhotoByObjectKey(String objectKey) async {
    try {
      final url = S3PathService.publicUrlForKey(objectKey);
      final uri = Uri.parse(url);
      final response = AppConfig.hasAwsCredentials
          ? await http.get(uri, headers: AwsSigV4Signer.signedGetHeaders(uri))
          : await http.get(uri);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Uint8List.fromList(response.bodyBytes);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Uri _buildListUri({required String prefix, String? continuationToken}) {
    final baseForListing = Uri.parse(
      S3PathService.publicUrlForKey('placeholder'),
    );
    return Uri(
      scheme: baseForListing.scheme,
      host: baseForListing.host,
      port: baseForListing.hasPort ? baseForListing.port : null,
      path: '/',
      queryParameters: <String, String>{
        'list-type': '2',
        'prefix': prefix,
        if (continuationToken != null && continuationToken.isNotEmpty)
          'continuation-token': continuationToken,
      },
    );
  }

  String _xmlUnescape(String value) {
    return value
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'");
  }

  void close() {}
}

class _PresignedUpload {
  const _PresignedUpload({required this.uploadUri, required this.headers});

  final Uri uploadUri;
  final Map<String, String> headers;
}
