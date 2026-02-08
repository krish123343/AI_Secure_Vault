import 'dart:io';
import 'package:image/image.dart' as img;

class FaceCompareService {
  /// MSE based comparison
  /// < 0.18 = MATCH
  static Future<double> compare(File a, File b) async {
    try {
      final imgA = img.decodeImage(await a.readAsBytes());
      final imgB = img.decodeImage(await b.readAsBytes());

      if (imgA == null || imgB == null) return 1.0;

      final aSmall = img.copyResize(imgA, width: 64, height: 64);
      final bSmall = img.copyResize(imgB, width: 64, height: 64);

      double mse = 0;

      for (int y = 0; y < 64; y++) {
        for (int x = 0; x < 64; x++) {
          final p1 = aSmall.getPixel(x, y);
          final p2 = bSmall.getPixel(x, y);

          final l1 = img.getLuminance(p1);
          final l2 = img.getLuminance(p2);

          mse += (l1 - l2) * (l1 - l2);
        }
      }

      return mse / (64 * 64) / (255 * 255);
    } catch (_) {
      return 1.0;
    }
  }
}
