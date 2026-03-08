import 'package:akshaja_insignia/src/config/app_config.dart';
import 'package:akshaja_insignia/src/domain/photo_record.dart';
import 'package:intl/intl.dart';

class S3PathService {
  const S3PathService._();

  static String objectKeyForRecord(PhotoRecord record) {
    final localTime = record.capturedAt.toLocal();
    final year = DateFormat('yyyy').format(localTime);
    final month = DateFormat('MM').format(localTime);
    final day = DateFormat('dd').format(localTime);
    final prefix = AppConfig.s3Prefix.replaceAll(RegExp(r'^/+|/+$'), '');
    return '$prefix/$year/$month/$day/${record.id}.avif';
  }

  static String _legacyObjectKeyMonthDay(PhotoRecord record) {
    final localTime = record.capturedAt.toLocal();
    final year = DateFormat('yyyy').format(localTime);
    final monthDay = DateFormat('MMM-dd', 'en_US').format(localTime);
    final prefix = AppConfig.s3Prefix.replaceAll(RegExp(r'^/+|/+$'), '');
    return '$prefix/$year/$monthDay/${record.id}.avif';
  }

  static String _legacyObjectKeyJpg(PhotoRecord record) {
    final localTime = record.capturedAt.toLocal();
    final year = DateFormat('yyyy').format(localTime);
    final month = DateFormat('MM').format(localTime);
    final day = DateFormat('dd').format(localTime);
    final prefix = AppConfig.s3Prefix.replaceAll(RegExp(r'^/+|/+$'), '');
    return '$prefix/$year/$month/$day/${record.id}.jpg';
  }

  static String publicUrlForRecord(PhotoRecord record) {
    return publicUrlForKey(objectKeyForRecord(record));
  }

  static List<String> publicUrlsForRecord(PhotoRecord record) {
    final keys = <String>[
      objectKeyForRecord(record),
      _legacyObjectKeyMonthDay(record),
      _legacyObjectKeyJpg(record),
    ];
    return keys.map(publicUrlForKey).toSet().toList();
  }

  static String publicUrlForKey(String objectKey) {
    final encodedPath = objectKey
        .split('/')
        .where((segment) => segment.isNotEmpty)
        .map(Uri.encodeComponent)
        .join('/');

    final customBase = AppConfig.s3PublicBaseUrl.trim();
    if (customBase.isNotEmpty) {
      final base = customBase.endsWith('/')
          ? customBase.substring(0, customBase.length - 1)
          : customBase;
      return '$base/$encodedPath';
    }

    return 'https://${AppConfig.s3Bucket}.s3.${AppConfig.awsRegion}.amazonaws.com/$encodedPath';
  }
}
