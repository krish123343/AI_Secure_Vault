import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/foundation.dart';
class FaceDetectionScreen extends StatefulWidget {
  const FaceDetectionScreen({super.key});

  @override
  State<FaceDetectionScreen> createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  late CameraController _cameraController;
  bool _isBusy = false;
  late FaceDetector _faceDetector;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: true,
        enableLandmarks: true,
      ),
    );
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    _cameraController =
        CameraController(camera, ResolutionPreset.medium, enableAudio: false);

    await _cameraController.initialize();

    _cameraController.startImageStream((CameraImage image) {
      if (_isBusy) return;
      _isBusy = true;

      _processImage(image);
    });

    setState(() {});
  }

  Future<void> _processImage(CameraImage image) async {
    try {
      final Uint8List bytes = _concatenatePlanes(image.planes);

      final InputImage inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );

      final faces = await _faceDetector.processImage(inputImage);

      print("Faces detected: ${faces.length}");
    } catch (e) {
      print("Error: $e");
    }

    _isBusy = false;
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer buffer = WriteBuffer();
    for (final Plane plane in planes) {
      buffer.putUint8List(plane.bytes);
    }
    return buffer.done().buffer.asUint8List();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Face Detection"),
        backgroundColor: Colors.black,
      ),
      body: _cameraController.value.isInitialized
          ? CameraPreview(_cameraController)
          : const Center(child: CircularProgressIndicator()),
    );
  }
}