import 'dart:io';
import 'package:ai_secure_access/widgets/face_painter.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;
import '../main.dart';
import '../services/facenet_service.dart';
import '../services/face_storage_service.dart';
import '../services/email_alert_service.dart';
import 'package:ai_secure_access/constants/app_colors.dart';

class FaceDetectionScreen extends StatefulWidget {
  const FaceDetectionScreen({super.key});

  @override
  State<FaceDetectionScreen> createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  CameraController? _controller;
  late FaceDetector _faceDetector;
  Face? _detectedFace;

  final FaceNetService _faceNet = FaceNetService();
  static const double threshold = 0.45;

  bool _isRegistered = false;
  bool _loading = true;
  String _status = "Initializing camera...";
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _isRegistered = prefs.getBool("face_registered") ?? false;

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableTracking: true,
      ),
    );

    await _faceNet.loadModel();
    await _initializeCamera();

    if (mounted) {
      setState(() {
        _loading = false;
        _status = _isRegistered ? "Detect your face" : "Register your face";
      });

      if (_controller != null && _controller!.value.isInitialized) {
        _startImageStream();
      }
    }
  }

  Future<void> _initializeCamera() async {
    final frontCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21 // NV21 for Android
          : ImageFormatGroup.bgra8888, // BGRA8888 for iOS
    );

    await _controller!.initialize();
  }

  void _startImageStream() {
    if (_controller == null) return;

    _controller!.startImageStream((CameraImage image) async {
      if (_isDetecting) return;
      _isDetecting = true;

      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) {
        _isDetecting = false;
        return;
      }

      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        if (mounted) {
          setState(() => _detectedFace = faces.first);
        }
      } else {
        if (mounted) {
          setState(() => _detectedFace = null);
        }
      }

      _isDetecting = false;
    });
  }

  Future<void> _takePictureAndProcess() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final picture = await _controller!.takePicture();
      final inputImage = InputImage.fromFilePath(picture.path);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        _updateStatus("No face detected. Please try again.");
        return;
      }

      final bytes = await File(picture.path).readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) {
        _updateStatus("Failed to process image.");
        return;
      }

      if (_isRegistered) {
        _detectAndMatchFace(image, File(picture.path));
      } else {
        _registerFace(image);
      }
    } catch (e) {
      _updateStatus("Error: ${e.toString()}");
    }
  }

  Future<void> _registerFace(img.Image image) async {
    _updateStatus("Registering face...");
    final embedding = _faceNet.getEmbedding(image);
    await FaceStorageService.saveEmbedding(embedding);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("face_registered", true);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Face registered successfully")),
    );
    Navigator.pushReplacementNamed(context, "/pin-setup");
  }

  Future<void> _detectAndMatchFace(img.Image image, File imageFile) async {
    _updateStatus("Detecting face...");
    final storedEmbedding = await FaceStorageService.loadEmbedding();
    if (storedEmbedding == null) {
      _updateStatus("No registered face found. Please register first.");
      return;
    }

    final currentEmbedding = _faceNet.getEmbedding(image);
    final distance = _faceNet.cosineDistance(storedEmbedding, currentEmbedding);

    if (!mounted) return;
    if (distance < threshold) {
      Navigator.pushReplacementNamed(context, "/vault");
    } else {
      final timestamp = DateTime.now().toString();
      await EmailAlertService.sendIntruderEmail(imageFile, timestamp);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Intruder detected! Alert sent.")),
      );
      _updateStatus("Intruder detected! Please try again.");
    }
  }

  void _updateStatus(String status) {
    if (mounted) {
      setState(() {
        _status = status;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final size = MediaQuery.of(context).size;
    final cameraSize = _controller!.value.previewSize!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          Center(
            child: AspectRatio(
              aspectRatio: cameraSize.height / cameraSize.width,
              child: CameraPreview(_controller!),
            ),
          ),

          // Face Bounding Box
          if (_detectedFace != null)
            CustomPaint(
              size: size,
              painter: FacePainter(
                imageSize: cameraSize,
                face: _detectedFace!,
              ),
            ),

          // UI Overlay
          _buildUIOverlay(),
        ],
      ),
    );
  }

  Widget _buildUIOverlay() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha((255 * 0.5).round()),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _status,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            FloatingActionButton(
              onPressed: _takePictureAndProcess,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.camera_alt, color: Colors.white),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, "/pin"),
              child: const Text(
                "Unlock with PIN",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final InputImageRotation? rotation =
        InputImageRotationValue.fromRawValue(_controller!.description.sensorOrientation);

    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);

    if (format == null) return null;

    return InputImage.fromBytes(
      bytes: image.planes.first.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }
}
