import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';

class WatermarkService {
  const WatermarkService();

  List<int> stampPhoto({
    required List<int> sourceBytes,
    required DateTime capturedAt,
    required double latitude,
    required double longitude,
  }) {
    final decoded = img.decodeImage(Uint8List.fromList(sourceBytes));
    if (decoded == null) {
      throw Exception('Unable to decode image bytes.');
    }

    final lines = <String>[
      'Date: ${DateFormat('dd-MM-yyyy').format(capturedAt.toLocal())}',
      'Time: ${DateFormat('HH:mm:ss').format(capturedAt.toLocal())}',
      'Lat: ${latitude.toStringAsFixed(6)}',
      'Lng: ${longitude.toStringAsFixed(6)}',
    ];

    final font = decoded.width >= 1400
        ? img.arial48
        : decoded.width >= 900
            ? img.arial24
            : img.arial14;

    final lineHeight = decoded.width >= 1400
        ? 54
        : decoded.width >= 900
            ? 30
            : 18;
    final padding = decoded.width >= 1400
        ? 28
        : decoded.width >= 900
            ? 20
            : 12;
    final overlayHeight = math.min(
      decoded.height,
      (lines.length * lineHeight) + (padding * 2),
    );
    final startY = decoded.height - overlayHeight;

    img.fillRect(
      decoded,
      x1: 0,
      y1: startY,
      x2: decoded.width - 1,
      y2: decoded.height - 1,
      color: img.ColorRgba8(0, 0, 0, 180),
    );

    var y = startY + padding;
    for (final line in lines) {
      img.drawString(
        decoded,
        line,
        font: font,
        x: padding,
        y: y,
        color: img.ColorRgb8(255, 255, 255),
      );
      y += lineHeight;
    }

    return img.encodeJpg(decoded, quality: 92);
  }
}
