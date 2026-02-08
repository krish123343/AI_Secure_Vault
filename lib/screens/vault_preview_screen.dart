import 'dart:typed_data';
import 'package:flutter/material.dart';

class VaultPreviewScreen extends StatelessWidget {
  final Uint8List bytes;
  final String fileName;

  const VaultPreviewScreen({
    super.key,
    required this.bytes,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    final isImage = fileName.endsWith(".jpg") ||
        fileName.endsWith(".png") ||
        fileName.endsWith(".jpeg");

    return Scaffold(
      appBar: AppBar(title: Text(fileName)),
      body: Center(
        child: isImage
            ? Image.memory(bytes)
            : const Text("Preview not supported"),
      ),
    );
  }
}
