import 'dart:convert';
import 'dart:typed_data';

import 'package:akshaja_insignia/src/config/app_config.dart';
import 'package:crypto/crypto.dart';

class AwsSigV4Signer {
  const AwsSigV4Signer._();

  static const String _service = 's3';
  static const String _algorithm = 'AWS4-HMAC-SHA256';

  static Map<String, String> signedPutHeaders(Uri uri, Uint8List payload) {
    return _signedHeaders(
      method: 'PUT',
      uri: uri,
      payloadHash: _sha256Hex(payload),
      contentType: 'image/avif',
    );
  }

  static Map<String, String> signedGetHeaders(Uri uri) {
    final emptyHash = _sha256Hex(Uint8List(0));
    return _signedHeaders(method: 'GET', uri: uri, payloadHash: emptyHash);
  }

  static Map<String, String> _signedHeaders({
    required String method,
    required Uri uri,
    required String payloadHash,
    String? contentType,
  }) {
    final now = DateTime.now().toUtc();
    final amzDate = _amzDate(now);
    final dateStamp = _dateStamp(now);
    final host = uri.host;

    final headers = <String, String>{
      'host': host,
      'x-amz-content-sha256': payloadHash,
      'x-amz-date': amzDate,
      'content-type': ?contentType,
      if (AppConfig.awsSessionToken.isNotEmpty)
        'x-amz-security-token': AppConfig.awsSessionToken,
    };

    final canonicalHeaders = _canonicalHeaders(headers);
    final signedHeaders = _signedHeadersList(headers);
    final canonicalRequest = [
      method,
      _canonicalUri(uri),
      _canonicalQuery(uri),
      canonicalHeaders,
      signedHeaders,
      payloadHash,
    ].join('\n');

    final credentialScope =
        '$dateStamp/${AppConfig.awsRegion}/$_service/aws4_request';
    final stringToSign = [
      _algorithm,
      amzDate,
      credentialScope,
      _sha256Hex(utf8.encode(canonicalRequest)),
    ].join('\n');

    final signingKey = _signingKey(
      AppConfig.awsSecretAccessKey,
      dateStamp,
      AppConfig.awsRegion,
      _service,
    );
    final signature = Hmac(
      sha256,
      signingKey,
    ).convert(utf8.encode(stringToSign)).toString();

    final authorization =
        '$_algorithm Credential=${AppConfig.awsAccessKeyId}/$credentialScope, '
        'SignedHeaders=$signedHeaders, Signature=$signature';

    return <String, String>{...headers, 'Authorization': authorization};
  }

  static String _canonicalUri(Uri uri) => uri.path.isEmpty ? '/' : uri.path;

  static String _canonicalQuery(Uri uri) {
    if (uri.queryParametersAll.isEmpty) {
      return '';
    }

    final entries = <String>[];
    final keys = uri.queryParametersAll.keys.toList()..sort();
    for (final key in keys) {
      final values = uri.queryParametersAll[key] ?? const <String>[];
      final sortedValues = [...values]..sort();
      for (final value in sortedValues) {
        entries.add('${_rfc3986Encode(key)}=${_rfc3986Encode(value)}');
      }
    }
    return entries.join('&');
  }

  static String _canonicalHeaders(Map<String, String> headers) {
    final keys = headers.keys.map((k) => k.toLowerCase()).toList()..sort();
    final normalized = <String, String>{
      for (final e in headers.entries) e.key.toLowerCase(): e.value.trim(),
    };
    return '${keys.map((k) => '$k:${normalized[k]}').join('\n')}\n';
  }

  static String _signedHeadersList(Map<String, String> headers) {
    final keys = headers.keys.map((k) => k.toLowerCase()).toList()..sort();
    return keys.join(';');
  }

  static List<int> _signingKey(
    String secret,
    String dateStamp,
    String region,
    String service,
  ) {
    final kDate = Hmac(
      sha256,
      utf8.encode('AWS4$secret'),
    ).convert(utf8.encode(dateStamp)).bytes;
    final kRegion = Hmac(sha256, kDate).convert(utf8.encode(region)).bytes;
    final kService = Hmac(sha256, kRegion).convert(utf8.encode(service)).bytes;
    return Hmac(sha256, kService).convert(utf8.encode('aws4_request')).bytes;
  }

  static String _sha256Hex(List<int> data) => sha256.convert(data).toString();

  static String _dateStamp(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year$month$day';
  }

  static String _amzDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final second = date.second.toString().padLeft(2, '0');
    return '$year$month${day}T$hour$minute${second}Z';
  }

  static String _rfc3986Encode(String value) {
    return Uri.encodeQueryComponent(
      value,
    ).replaceAll('+', '%20').replaceAll('*', '%2A').replaceAll('%7E', '~');
  }
}
