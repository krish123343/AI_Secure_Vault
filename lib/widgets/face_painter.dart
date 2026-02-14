
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FacePainter extends CustomPainter {
  final Size imageSize;
  final Face face;

  FacePainter({required this.imageSize, required this.face});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.red;

    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    final rect = Rect.fromLTRB(
      face.boundingBox.left * scaleX,
      face.boundingBox.top * scaleY,
      face.boundingBox.right * scaleX,
      face.boundingBox.bottom * scaleY,
    );

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.face != face;
  }
}
