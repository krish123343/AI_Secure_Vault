import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class ImageConverter {
  static Uint8List fromPlanes(List<Plane> planes) {
    final WriteBuffer buffer = WriteBuffer();
    for (final Plane p in planes) {
      buffer.putUint8List(p.bytes);
    }
    return buffer.done().buffer.asUint8List();
  }
}