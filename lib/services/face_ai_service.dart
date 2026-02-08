import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceAIService {
  static Interpreter? _interpreter;

  /// Load FaceNet TFLite model
  static Future<void> loadModel() async {
    _interpreter ??=
        await Interpreter.fromAsset('assets/models/facenet.tflite');
  }

  /// Generate 512-D face embedding
  static List<double> getEmbedding(img.Image image) {
    final resized = img.copyResize(image, width: 160, height: 160);

    final input = List.generate(
      1,
      (_) => List.generate(
        160,
        (y) => List.generate(
          160,
          (x) {
            final pixel = resized.getPixel(x, y);

            return [
              (pixel.r - 127.5) / 128.0,
              (pixel.g - 127.5) / 128.0,
              (pixel.b - 127.5) / 128.0,
            ];
          },
        ),
      ),
    );

    final output = List.generate(1, (_) => List.filled(512, 0.0));

    _interpreter!.run(input, output);

    return output.first;
  }

  /// Cosine similarity between embeddings
  static double similarity(List<double> a, List<double> b) {
    double dot = 0, na = 0, nb = 0;

    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      na += a[i] * a[i];
      nb += b[i] * b[i];
    }

    return dot / (sqrt(na) * sqrt(nb));
  }
}
