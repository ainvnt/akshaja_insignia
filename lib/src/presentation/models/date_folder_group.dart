import 'package:akshaja_insignia/src/domain/photo_record.dart';

class DateFolderGroup {
  const DateFolderGroup({required this.key, required this.photos});

  final String key;
  final List<PhotoRecord> photos;
}
