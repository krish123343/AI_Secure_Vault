import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceNetService {
  static const int inputSize = 160;
  static const int embeddingSize = 512;

  late Interpreter _interpreter;

  /// Load FaceNet TFLite model
  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/models/facenet.tflite',
      options: InterpreterOptions()..threads = 2,
    );
  }

  /// Convert face image to 512-D embedding
  List<double> getEmbedding(img.Image faceImage) {
    final resized =
        img.copyResize(faceImage, width: inputSize, height: inputSize);

    final input = List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (y) => List.generate(
          inputSize,
          (x) {
            final p = resized.getPixel(x, y);

            return [
              (p.r - 127.5) / 128.0,
              (p.g - 127.5) / 128.0,
              (p.b - 127.5) / 128.0,
            ];
          },
        ),
      ),
    );

    final output =
        List.generate(1, (_) => List.filled(embeddingSize, 0.0));

    _interpreter.run(input, output);
    return output.first;
  }

  /// Cosine distance (lower = more similar)
  double cosineDistance(List<double> a, List<double> b) {
    double dot = 0, normA = 0, normB = 0;

    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    return 1 - (dot / (sqrt(normA) * sqrt(normB)));
  }
}
