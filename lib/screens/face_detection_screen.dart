import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;
import '../main.dart';
import '../services/facenet_service.dart';
import '../services/face_storage_service.dart';
import '../services/email_alert_service.dart';

class FaceDetectionScreen extends StatefulWidget {
  const FaceDetectionScreen({super.key});

  @override
  State<FaceDetectionScreen> createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  CameraController? _controller;
  late FaceDetector _faceDetector;

  // 🧠 FaceNet AI
  final FaceNetService _faceNet = FaceNetService();
  static const double threshold = 0.45;

  bool _isRegistered = false;
  bool _loading = true;
  String _status = "Initializing camera...";

  @override
  void initState() {
    super.initState();
    _init();
  }

  // --------------------------------------------------
  // INIT
  // --------------------------------------------------
  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _isRegistered = prefs.getBool("face_registered") ?? false;

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
      ),
    );

    await _faceNet.loadModel();
    await _initializeCamera();

    if (!mounted) return;
    setState(() {
      _loading = false;
      _status = _isRegistered ? "Detect your face" : "Register your face";
    });
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
    );

    await _controller!.initialize();
  }

  // --------------------------------------------------
  // REGISTER FACE
  // --------------------------------------------------
  Future<void> _registerFace() async {
    if (!mounted) return;
    setState(() => _status = "Registering face...");

    final picture = await _controller!.takePicture();
    final faces = await _faceDetector.processImage(
      InputImage.fromFilePath(picture.path),
    );

    if (faces.isEmpty) {
      if (!mounted) return;
      setState(() => _status = "No face detected. Try again.");
      return;
    }

    final bytes = await File(picture.path).readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      if (!mounted) return;
      setState(() => _status = "Image processing failed");
      return;
    }

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

  // --------------------------------------------------
  // DETECT & MATCH FACE
  // --------------------------------------------------
  Future<void> _detectFace() async {
    if (!mounted) return;
    setState(() => _status = "Detecting face...");

    final storedEmbedding = await FaceStorageService.loadEmbedding();
    if (storedEmbedding == null) {
      if (!mounted) return;
      setState(() => _status = "No registered face found");
      return;
    }

    final picture = await _controller!.takePicture();
    final faces = await _faceDetector.processImage(
      InputImage.fromFilePath(picture.path),
    );

    if (faces.isEmpty) {
      if (!mounted) return;
      setState(() => _status = "No face detected");
      return;
    }

    final bytes = await File(picture.path).readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      if (!mounted) return;
      setState(() => _status = "Image processing failed");
      return;
    }

    final currentEmbedding = _faceNet.getEmbedding(image);
    final distance =
        _faceNet.cosineDistance(storedEmbedding, currentEmbedding);

    if (distance < threshold) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/vault");
    } else {
      final timestamp = DateTime.now().toString();
      await EmailAlertService.sendIntruderEmail(
        File(picture.path),
        timestamp,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Intruder detected! Alert sent.")),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  // --------------------------------------------------
  // UI
  // --------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (_loading ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Face Access"), centerTitle: true),
      body: Stack(
        children: [
          CameraPreview(_controller!),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 8),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_status, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _isRegistered ? _detectFace : _registerFace,
                      child: Text(
                        _isRegistered
                            ? "Detect Face & Enter Vault"
                            : "Register Face",
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/pin");
                      },
                      child: const Text(
                        "Unlock with PIN",
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
