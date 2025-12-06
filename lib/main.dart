// lib/main.dart
// FULL UPDATED main.dart (Option B: Keep Home, Auto-Recognition once registered)
// PART 1/8 
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
 // file picker added

List<CameraDescription>? cameras;

/// -------------------- MAIN --------------------
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const AISecureAccessApp());
}

/// -------------------- APP --------------------
class AISecureAccessApp extends StatelessWidget {
  const AISecureAccessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Secure Access',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey, brightness: Brightness.dark),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      home: const SplashScreen(),
    );
  }
}

/// -------------------- SPLASH SCREEN --------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();

    // navigate to Home after splash
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2F4156),
      body: Center(
        child: ScaleTransition(
          scale: _scale,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/icon/logo.png', height: 140, width: 140),
              const SizedBox(height: 18),
              Text('AI Secure Access', style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Smart security powered by AI', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

/// -------------------- HOME SCREEN --------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _tiltController;
  late final Animation<double> _tiltAnim;

  @override
  void initState() {
    super.initState();
    _tiltController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _tiltAnim = Tween<double>(begin: -0.06, end: 0.06).animate(CurvedAnimation(parent: _tiltController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _tiltController.dispose();
    super.dispose();
  }

  Widget _glassButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.white.withOpacity(0.12), Colors.white.withOpacity(0.04)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(icon, color: Colors.white), const SizedBox(width: 10), Text(label, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16))],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(colors: [Color(0xFF0F1720), Color(0xFF2F4156), Color(0xFF3D4F63)], begin: Alignment.topLeft, end: Alignment.bottomRight);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color.fromARGB(0, 0, 0, 0),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: Text('AI Secure Access', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600))),
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0),
          child: Column(
            children: [
              const SizedBox(height: 110),
              AnimatedBuilder(
                animation: _tiltAnim,
                builder: (_, child) {
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(_tiltAnim.value),
                    child: child,
                  );
                },
                child: Image.asset('assets/icon/logo.png', height: 150),
              ),
              const SizedBox(height: 28),
              Text('Welcome to\nAI Secure Access', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 12),
              Text('Smart security powered by AI.\nChoose an option to begin.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 15, color: Colors.white70)),
              const SizedBox(height: 40),

              // Add Video navigates to VaultVideosScreen (picker inside vault)
              _glassButton(icon: Icons.video_library, label: 'Add Video', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VaultVideosScreen()))),
              const SizedBox(height: 16),

              _glassButton(icon: Icons.lock_open, label: 'Start Face Access', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FaceDetectionScreen()))),
            ],
          ),
        ),
      ),
    );
  }
}

/// -------------------- FACE DETECTION SCREEN --------------------
class FaceDetectionScreen extends StatefulWidget {
  const FaceDetectionScreen({super.key});

  @override
  State<FaceDetectionScreen> createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  CameraController? controller;
  bool _detectingFaces = false;
  String _status = "Waiting for scan...";
  File? _lastMatchedFace;

  bool _faceAlreadyRegistered = false;

  // NEW VARIABLES FOR FACE BOX
  List<Face> _detectedFaces = [];
  InputImageRotation? _rotation;

  // Email + user config
  bool _autoEmailOnDeny = true;
  String _userName = "";
  String _recipientEmail = "";
  String _smtpUser = "";
  String _smtpPass = "";

  final _key = encrypt.Key.fromLength(32);
  final _iv = encrypt.IV.fromLength(16);

  // Files
  static const _faceDirName = 'registered_faces';
  static const _intruderDirName = 'intruders';
  static const _registeredUsersFile = 'registered_users.json';
  static const _intruderLogFile = 'intruder_logs.json';

  static const _vaultPicturesFile = 'vault_pictures.json';
  static const _vaultVideosFile = 'vault_videos.json';
  static const _vaultDocsFile = 'vault_documents.json';
  static const _vaultAudioFile = 'vault_audio.json';
  static const _vaultAppsFile = 'vault_apps.json';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkIfFaceExists();
    _initializeCamera();
  }

  Future<Directory> _appDocDir() async =>
      await getApplicationDocumentsDirectory();

  /// ---------------- CHECK IF FACE ALREADY REGISTERED ----------------
  Future<void> _checkIfFaceExists() async {
    final dir = await _appDocDir();
    final f = File('${dir.path}/$_registeredUsersFile');

    if (await f.exists()) {
      try {
        final data = json.decode(await f.readAsString()) as List<dynamic>;
        if (data.isNotEmpty) {
          setState(() => _faceAlreadyRegistered = true);
          Future.delayed(const Duration(milliseconds: 400), () {
            if (mounted) captureAndDetect();
          });
        }
      } catch (_) {}
    }
  }

  /// ---------------- LOAD SETTINGS ----------------
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedPass = prefs.getString('smtpPass') ?? "";

    final encrypter = encrypt.Encrypter(encrypt.AES(_key));

    setState(() {
      _autoEmailOnDeny = prefs.getBool('autoEmail') ?? true;
      _userName = prefs.getString('userName') ?? "";
      _recipientEmail = prefs.getString('recipientEmail') ?? "";
      _smtpUser = prefs.getString('smtpUser') ?? "";

      try {
        _smtpPass = encryptedPass.isEmpty
            ? ""
            : encrypter.decrypt64(encryptedPass, iv: _iv);
      } catch (_) {
        _smtpPass = "";
      }
    });
  }

  /// ---------------- INITIALIZE CAMERA ----------------
  Future<void> _initializeCamera() async {
    if (cameras == null || cameras!.isEmpty) return;

    final frontCam = cameras!.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras!.first);

    controller = CameraController(
      frontCam,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Camera init error: $e");
    }
  }

  /// ---------------- REGISTER FACE ----------------
  Future<void> registerMyFace() async {
    if (_faceAlreadyRegistered) {
      _showSnack("Face already registered");
      return;
    }

    if (!controller!.value.isInitialized) {
      _showSnack("Camera not ready");
      return;
    }

    try {
      final pic = await controller!.takePicture();
      final dir = await _appDocDir();

      final folder = Directory('${dir.path}/$_faceDirName');
      if (!await folder.exists()) await folder.create(recursive: true);

      final nameCtrl = TextEditingController();
      final name = await showDialog<String?>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text("Register Face"),
          content: TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: "Enter name"),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(c, null),
                child: const Text("Cancel")),
            TextButton(
                onPressed: () => Navigator.pop(c, nameCtrl.text.trim()),
                child: const Text("Save")),
          ],
        ),
      );

      if (name == null || name.isEmpty) return;

      final ts = DateTime.now().millisecondsSinceEpoch;
      final saved = File('${folder.path}/$name-$ts.jpg');
      await File(pic.path).copy(saved.path);

      final meta = File('${dir.path}/$_registeredUsersFile');
      List list = [];
      if (await meta.exists()) {
        try {
          list = json.decode(await meta.readAsString());
        } catch (_) {}
      }

      list.add({
        'name': name,
        'file': saved.path.split(Platform.pathSeparator).last,
        'timestamp': DateTime.now().toIso8601String(),
      });

      await meta.writeAsString(json.encode(list), flush: true);

      setState(() {
        _faceAlreadyRegistered = true;
        _lastMatchedFace = saved;
        _status = "Face Registered";
      });

      _showSnack("Face registered!");
    } catch (e) {
      _showSnack("Error: $e");
    }
  }

  /// ---------------- IMAGE SIMILARITY ----------------
  double _imageSimilarity(File aFile, File bFile) {
    try {
      final a = img.decodeImage(aFile.readAsBytesSync());
      final b = img.decodeImage(bFile.readAsBytesSync());
      if (a == null || b == null) return double.infinity;

      final aSmall = img.copyResize(a, width: 64, height: 64);
      final bSmall = img.copyResize(b, width: 64, height: 64);

      double mse = 0;
      for (int i = 0; i < 64; i++) {
        for (int j = 0; j < 64; j++) {
          final p1 = aSmall.getPixel(j, i);
          final p2 = bSmall.getPixel(j, i);

          final l1 = 0.299 * p1.r + 0.587 * p1.g + 0.114 * p1.b;
          final l2 = 0.299 * p2.r + 0.587 * p2.g + 0.114 * p2.b;

          mse += (l1 - l2) * (l1 - l2);
        }
      }

      mse /= (64 * 64);
      return mse / (255 * 255);
    } catch (_) {
      return double.infinity;
    }
  }

  /// ---------------- FIND BEST MATCH ----------------
  Future<Map<String, dynamic>?> _findBestMatch(File probe,
      {double threshold = 0.038}) async {
    final dir = await _appDocDir();
    final meta = File('${dir.path}/$_registeredUsersFile');

    if (!await meta.exists()) return null;

    List raw = json.decode(await meta.readAsString());
    final facesDir = Directory('${dir.path}/$_faceDirName');

    double bestScore = double.infinity;
    Map<String, dynamic>? bestUser;

    for (var u in raw) {
      final f = File('${facesDir.path}/${u['file']}');
      if (await f.exists()) {
        final score = _imageSimilarity(f, probe);

        if (score < bestScore) {
          bestScore = score;
          bestUser = Map<String, dynamic>.from(u);
          bestUser['score'] = score;
        }
      }
    }

    if (bestUser != null && bestUser['score'] <= threshold) {
      return bestUser;
    }

    return null;
  }

  /// ---------------- CAPTURE & DETECT ----------------
  Future<void> captureAndDetect() async {
    if (_detectingFaces) return;

    if (!controller!.value.isInitialized) {
      _showSnack("Camera not ready");
      return;
    }

    setState(() {
      _detectingFaces = true;
      _status = "Scanning...";
    });

    try {
      final shot = await controller!.takePicture();
      final probe = File(shot.path);

      // ML KIT FACE PROCESSING
      final inputImage = InputImage.fromFilePath(probe.path);
      final faceDetector = FaceDetector(
        options: FaceDetectorOptions(
            performanceMode: FaceDetectorMode.accurate),
      );

      final faces = await faceDetector.processImage(inputImage);

      // UPDATE FACE BOXES
      setState(() {
        _detectedFaces = faces;
      });

      if (faces.isEmpty) {
        setState(() => _status = "No face found");
      } else {
        final match = await _findBestMatch(probe);

        if (match != null) {
          setState(() => _status = "Authorized: ${match['name']}");
          await Future.delayed(const Duration(milliseconds: 600));

          if (!mounted) return;
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => const VaultScreen()));
        } else {
          setState(() => _status = "Unauthorized");
          await _handleIntruder(probe);
        }
      }

      await faceDetector.close();
    } catch (e) {
      setState(() => _status = "Error");
    }

    if (mounted) setState(() => _detectingFaces = false);
  }

  /// ---------------- HANDLE INTRUDER ----------------
  Future<void> _handleIntruder(File image) async {
    try {
      final dir = await _appDocDir();
      final f = Directory('${dir.path}/$_intruderDirName');
      if (!await f.exists()) await f.create(recursive: true);

      final ts = DateTime.now().millisecondsSinceEpoch;
      final saved = File('${f.path}/intruder_$ts.jpg');
      await image.copy(saved.path);

      final meta = File('${dir.path}/$_intruderLogFile');
      List logs = [];

      if (await meta.exists()) {
        try {
          logs = json.decode(await meta.readAsString());
        } catch (_) {}
      }

      logs.add({
        'file': saved.path.split(Platform.pathSeparator).last,
        'timestamp': DateTime.now().toIso8601String(),
        'emailSent': false,
      });

      await meta.writeAsString(json.encode(logs), flush: true);

      await _showOverlayDenied();
    } catch (_) {}
  }

  /// ---------------- SHOW OVERLAY ----------------
  Future<void> _showOverlayDenied() async {
    try {
      if (!(await FlutterOverlayWindow.isPermissionGranted() ?? false)) {
        await FlutterOverlayWindow.requestPermission();
        return;
      }

      await FlutterOverlayWindow.showOverlay(
        enableDrag: true,
        alignment: OverlayAlignment.center,
        height: 300,
        width: 300,
        overlayContent: '{"title":"Access Denied"}',
      );

      Future.delayed(const Duration(seconds: 4), () {
        FlutterOverlayWindow.closeOverlay();
      });
    } catch (_) {}
  }

  /// ---------------- UI ----------------
  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("AI Secure Access")),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Center(
              child: AspectRatio(
                aspectRatio: controller!.value.aspectRatio,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CameraPreview(controller!),

                    // FACE BOX OVERLAY
                    CustomPaint(
                      painter: FacePainter(
                        faces: _detectedFaces,
                        imageSize: controller!.value.previewSize!,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                _status,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (!_faceAlreadyRegistered)
            FloatingActionButton(
              heroTag: "register",
              onPressed: registerMyFace,
              child: const Icon(Icons.person_add),
            ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: "scan",
            onPressed: captureAndDetect,
            child: const Icon(Icons.face),
          ),
        ],
      ),
    );
  }
}

/// -------------------- FACE P
class FacePainter extends CustomPainter {
  final List<Face> faces;
  final Size imageSize;

  FacePainter({required this.faces, required this.imageSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Scale from image size to screen size
    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    for (var face in faces) {
      final rect = Rect.fromLTRB(
        face.boundingBox.left * scaleX,
        face.boundingBox.top * scaleY,
        face.boundingBox.right * scaleX,
        face.boundingBox.bottom * scaleY,
      );

      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) => true;
}
/// -------------------- VAULT SCREEN --------------------
class VaultScreen extends StatelessWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0C1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Vault',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _vaultTile(
              context,
              Icons.person,
              'Registered Users',
              Colors.teal,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RegisteredUsersScreen(),
                ),
              ),
            ),

            _vaultTile(
              context,
              Icons.photo,
              'Pictures',
              Colors.blueAccent,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const VaultPicturesScreen(),
                ),
              ),
            ),

            _vaultTile(
              context,
              Icons.videocam,
              'Videos',
              Colors.purpleAccent,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const VaultVideosScreen(),
                ),
              ),
            ),

            _vaultTile(
              context,
              Icons.apps,
              'Apps',
              Colors.greenAccent,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const VaultAppsScreen(),
                ),
              ),
            ),

            _vaultTile(
              context,
              Icons.mic,
              'Recordings',
              Colors.redAccent,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const VaultAudioScreen(),
                ),
              ),
            ),

            _vaultTile(
              context,
              Icons.insert_drive_file,
              'Documents',
              Colors.amberAccent,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const VaultDocumentsScreen(),
                ),
              ),
            ),

            _vaultTile(
              context,
              Icons.security,
              'Intruder Logs',
              Colors.orangeAccent,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const IntruderLogsScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// -------------------- Vault Tile Widget --------------------
Widget _vaultTile(
  BuildContext context,
  IconData icon,
  String title,
  Color glow,
  VoidCallback onTap,
) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B2F),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: glow.withOpacity(0.22),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: glow),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    ),
  );
}
/// -------------------- Registered Users Screen --------------------
class RegisteredUsersScreen extends StatefulWidget {
  const RegisteredUsersScreen({super.key});

  @override
  State<RegisteredUsersScreen> createState() => _RegisteredUsersScreenState();
}

class _RegisteredUsersScreenState extends State<RegisteredUsersScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<Directory> _appDocDir() async =>
      await getApplicationDocumentsDirectory();

  /// ---------------- LOAD ALL REGISTERED USERS ----------------
  Future<void> _loadUsers() async {
    setState(() => _loading = true);

    final dir = await _appDocDir();
    final file =
        File('${dir.path}/${_FaceDetectionScreenState._registeredUsersFile}');

    if (!await file.exists()) {
      setState(() {
        _users = [];
        _loading = false;
      });
      return;
    }

    try {
      final raw = json.decode(await file.readAsString()) as List<dynamic>;

      setState(() {
        _users =
            raw.map((e) => Map<String, dynamic>.from(e as Map)).toList().reversed.toList();
        _loading = false;
      });
    } catch (e) {
      debugPrint("Error loading users: $e");
      setState(() {
        _users = [];
        _loading = false;
      });
    }
  }

  /// ---------------- GET IMAGE FILE FROM STORAGE ----------------
  Future<File?> _getImageFile(String fileName) async {
    final dir = await _appDocDir();
    final file =
        File('${dir.path}/${_FaceDetectionScreenState._faceDirName}/$fileName');

    if (await file.exists()) return file;
    return null;
  }

  /// ---------------- DELETE USER ----------------
  Future<void> _deleteUser(Map<String, dynamic> user) async {
    final dir = await _appDocDir();
    final meta =
        File('${dir.path}/${_FaceDetectionScreenState._registeredUsersFile}');

    if (!await meta.exists()) return;

    try {
      final list = json.decode(await meta.readAsString()) as List<dynamic>;
      list.removeWhere((e) => e["file"] == user["file"]);

      await meta.writeAsString(json.encode(list), flush: true);
    } catch (e) {
      debugPrint("Delete meta error: $e");
    }

    final img = File(
        '${dir.path}/${_FaceDetectionScreenState._faceDirName}/${user["file"]}');

    try {
      if (await img.exists()) await img.delete();
    } catch (e) {
      debugPrint("Delete image error: $e");
    }

    await _loadUsers();
  }

  /// ---------------- CONFIRM DELETE DIALOG ----------------
  Future<void> _confirmDelete(Map<String, dynamic> user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Delete User"),
        content: Text("Remove ${user['name']} permanently?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text("Delete")),
        ],
      ),
    );

    if (confirm == true) {
      await _deleteUser(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0C1E),
      appBar: AppBar(
        title: const Text("Registered Users"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? const Center(
                  child: Text(
                    "No registered users yet.",
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (c, i) {
                    final user = _users[i];
                    final fileName = user["file"] ?? "";
                    final name = user["name"] ?? "Unknown";

                    final ts = user["timestamp"] ?? "";
                    final date = DateTime.tryParse(ts)
                            ?.toLocal()
                            .toString()
                            .split(".")
                            .first ??
                        ts;

                    return Card(
                      color: const Color(0xFF1B1B2F),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: FutureBuilder<File?>(
                          future: _getImageFile(fileName),
                          builder: (context, snap) {
                            if (!snap.hasData || snap.data == null) {
                              return const CircleAvatar(
                                backgroundColor: Colors.teal,
                                child: Icon(Icons.person, color: Colors.white),
                              );
                            }
                            return CircleAvatar(
                              backgroundImage: FileImage(snap.data!),
                            );
                          },
                        ),

                        title: Text(
                          name,
                          style: const TextStyle(color: Colors.white),
                        ),

                        subtitle: Text(
                          "Registered: $date",
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),

                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => _confirmDelete(user),
                        ),

                        onTap: () async {
                          final file = await _getImageFile(fileName);

                          if (file != null && mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    FullImageViewScreen(imageFile: file),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

/// -------------------- Full Image View --------------------
class FullImageViewScreen extends StatelessWidget {
  final File imageFile;

  const FullImageViewScreen({required this.imageFile, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Photo")),
      body: Center(
        child: Image.file(imageFile),
      ),
    );
  }
}
/// -------------------- Intruder Logs Screen --------------------
class IntruderLogsScreen extends StatefulWidget {
  const IntruderLogsScreen({super.key});

  @override
  State<IntruderLogsScreen> createState() => _IntruderLogsScreenState();
}

class _IntruderLogsScreenState extends State<IntruderLogsScreen> {
  List<Map<String, dynamic>> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<Directory> _appDocDir() async =>
      await getApplicationDocumentsDirectory();

  /// ---------------- LOAD ALL INTRUDER LOGS ----------------
  Future<void> _loadLogs() async {
    setState(() => _loading = true);

    final dir = await _appDocDir();
    final file =
        File('${dir.path}/${_FaceDetectionScreenState._intruderLogFile}');

    if (!await file.exists()) {
      setState(() {
        _logs = [];
        _loading = false;
      });
      return;
    }

    try {
      final raw = json.decode(await file.readAsString()) as List<dynamic>;

      setState(() {
        _logs =
            raw.map((e) => Map<String, dynamic>.from(e as Map)).toList().reversed.toList();
        _loading = false;
      });
    } catch (e) {
      debugPrint("Error loading intruder logs: $e");
      setState(() {
        _logs = [];
        _loading = false;
      });
    }
  }

  /// ---------------- GET INTRUDER IMAGE ----------------
  Future<File?> _getImageFile(String filename) async {
    final dir = await _appDocDir();
    final file =
        File('${dir.path}/${_FaceDetectionScreenState._intruderDirName}/$filename');

    if (await file.exists()) return file;
    return null;
  }

  /// ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0C1E),

      appBar: AppBar(
        title: const Text("Intruder Logs"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())

          : _logs.isEmpty
              ? const Center(
                  child: Text(
                    "No intruder logs yet.",
                    style: TextStyle(color: Colors.white70),
                  ),
                )

              : ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    final filename = log["file"] ?? "";
                    final timestamp = log["timestamp"] ?? "";
                    final emailSent = log["emailSent"] == true;

                    return Card(
                      color: const Color(0xFF1B1B2F),
                      margin:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: FutureBuilder<File?>(
                          future: _getImageFile(filename),
                          builder: (context, snap) {
                            if (!snap.hasData || snap.data == null) {
                              return const SizedBox(
                                width: 56,
                                height: 56,
                                child: Center(
                                  child: Icon(Icons.image_not_supported,
                                      color: Colors.white54),
                                ),
                              );
                            }

                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                snap.data!,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),

                        title: Text(
                          DateTime.tryParse(timestamp)
                                  ?.toLocal()
                                  .toString()
                                  .split(".")
                                  .first ??
                              timestamp,
                          style: const TextStyle(color: Colors.white),
                        ),

                        subtitle: Text(
                          emailSent ? "Email Alert Sent" : "Email Not Sent",
                          style: TextStyle(
                            color: emailSent
                                ? Colors.greenAccent
                                : Colors.redAccent,
                          ),
                        ),

                        trailing: IconButton(
                          icon: const Icon(Icons.open_in_full,
                              color: Colors.white),
                          onPressed: () async {
                            final imgFile = await _getImageFile(filename);

                            if (imgFile == null) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Image not found")),
                              );
                              return;
                            }

                            if (!mounted) return;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    FullImageViewScreen(imageFile: imgFile),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
/// -------------------- Vault Pictures Screen --------------------
class VaultPicturesScreen extends StatefulWidget {
  const VaultPicturesScreen({super.key});

  @override
  State<VaultPicturesScreen> createState() => _VaultPicturesScreenState();
}

class _VaultPicturesScreenState extends State<VaultPicturesScreen> {
  List<Map<String, dynamic>> _pics = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPictures();
  }

  Future<Directory> _appDir() async =>
      await getApplicationDocumentsDirectory();

  /// ---------------- LOAD PICTURE METADATA ----------------
  Future<void> _loadPictures() async {
    setState(() => _loading = true);

    final dir = await _appDir();
    final meta =
        File('${dir.path}/${_FaceDetectionScreenState._vaultPicturesFile}');

    if (!await meta.exists()) {
      setState(() {
        _pics = [];
        _loading = false;
      });
      return;
    }

    try {
      final raw = json.decode(await meta.readAsString()) as List<dynamic>;

      setState(() {
        _pics =
            raw.map((e) => Map<String, dynamic>.from(e as Map)).toList().reversed.toList();
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _pics = [];
        _loading = false;
      });
    }
  }

  /// ---------------- ADD IMAGE USING FILE PICKER ----------------
  Future<void> _addPicture() async {
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (picked == null) return;

      final srcPath = picked.files.single.path;
      if (srcPath == null) return;

      final srcFile = File(srcPath);

      final dir = await _appDir();
      final folder = Directory('${dir.path}/vault_pictures');

      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      final ts = DateTime.now().millisecondsSinceEpoch;
      final extension = _extensionOf(srcPath);
      final dest =
          File('${folder.path}/pic_$ts$extension');

      await srcFile.copy(dest.path);

      /// Save metadata
      final meta =
          File('${dir.path}/${_FaceDetectionScreenState._vaultPicturesFile}');
      List list = [];

      if (await meta.exists()) {
        try {
          list = json.decode(await meta.readAsString());
        } catch (_) {}
      }

      list.add({
        'file': dest.path.split(Platform.pathSeparator).last,
        'originalPath': srcPath,
        'timestamp': DateTime.now().toIso8601String(),
      });

      await meta.writeAsString(json.encode(list), flush: true);

      await _loadPictures();
    } catch (e) {
      debugPrint("Add picture error: $e");
    }
  }

  /// ---------------- GET FILE EXTENSION ----------------
  String _extensionOf(String path) {
    final idx = path.lastIndexOf('.');
    if (idx == -1) return ".jpg";
    return path.substring(idx);
  }

  /// ---------------- GET IMAGE FILE ----------------
  Future<File?> _getImage(String filename) async {
    final dir = await _appDir();
    final file =
        File('${dir.path}/vault_pictures/$filename');

    if (await file.exists()) return file;
    return null;
  }

  /// ---------------- DELETE IMAGE ----------------
  Future<void> _deletePicture(Map<String, dynamic> item) async {
    final dir = await _appDir();

    final meta =
        File('${dir.path}/${_FaceDetectionScreenState._vaultPicturesFile}');

    if (await meta.exists()) {
      try {
        final list = json.decode(await meta.readAsString()) as List<dynamic>;
        list.removeWhere((e) => e["file"] == item["file"]);
        await meta.writeAsString(json.encode(list), flush: true);
      } catch (e) {
        debugPrint("Delete meta error: $e");
      }
    }

    final file = File('${dir.path}/vault_pictures/${item["file"]}');
    if (await file.exists()) {
      await file.delete();
    }

    await _loadPictures();
  }

  /// ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vault Pictures"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addPicture,
          ),
        ],
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())

          : _pics.isEmpty
              ? const Center(
                  child: Text(
                    "No pictures added",
                    style: TextStyle(color: Colors.white70),
                  ),
                )

              : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: _pics.length,
                  itemBuilder: (context, index) {
                    final item = _pics[index];
                    final fname = item["file"] ?? "";

                    return FutureBuilder<File?>(
                      future: _getImage(fname),
                      builder: (ctx, snap) {
                        if (!snap.hasData || snap.data == null) {
                          return Container(
                            color: Colors.grey[800],
                            child: const Center(
                              child: Icon(Icons.broken_image,
                                  color: Colors.white),
                            ),
                          );
                        }

                        final file = snap.data!;

                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  FullImageViewScreen(imageFile: file),
                            ),
                          ),

                          onLongPress: () async {
                            final delete = await showDialog<bool>(
                              context: context,
                              builder: (c) => AlertDialog(
                                title: const Text("Delete Picture?"),
                                content: const Text("This cannot be undone."),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(c, false),
                                      child: const Text("Cancel")),
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(c, true),
                                      child: const Text("Delete")),
                                ],
                              ),
                            );

                            if (delete == true) {
                              await _deletePicture(item);
                            }
                          },

                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              file,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
/// -------------------- Vault Videos Screen --------------------
class VaultVideosScreen extends StatefulWidget {
  const VaultVideosScreen({super.key});

  @override
  State<VaultVideosScreen> createState() => _VaultVideosScreenState();
}

class _VaultVideosScreenState extends State<VaultVideosScreen> {
  List<Map<String, dynamic>> _videos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<Directory> _appDir() async =>
      await getApplicationDocumentsDirectory();

  /// ---------------- LOAD VIDEO METADATA ----------------
  Future<void> _loadVideos() async {
    setState(() => _loading = true);

    final dir = await _appDir();
    final file =
        File('${dir.path}/${_FaceDetectionScreenState._vaultVideosFile}');

    if (!await file.exists()) {
      setState(() {
        _videos = [];
        _loading = false;
      });
      return;
    }

    try {
      final raw = json.decode(await file.readAsString()) as List<dynamic>;

      setState(() {
        _videos =
            raw.map((e) => Map<String, dynamic>.from(e as Map)).toList().reversed.toList();
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _videos = [];
        _loading = false;
      });
    }
  }

  /// ---------------- ADD VIDEO USING FILE PICKER ----------------
  Future<void> _addVideo() async {
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (picked == null) return;

      final srcPath = picked.files.single.path;
      if (srcPath == null) return;

      final srcFile = File(srcPath);

      final dir = await _appDir();
      final folder = Directory('${dir.path}/vault_videos');

      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      final ts = DateTime.now().millisecondsSinceEpoch;
      final extension = _extensionOf(srcPath);

      final dest =
          File('${folder.path}/video_$ts$extension');

      await srcFile.copy(dest.path);

      /// Save metadata
      final meta =
          File('${dir.path}/${_FaceDetectionScreenState._vaultVideosFile}');
      List list = [];

      if (await meta.exists()) {
        try {
          list = json.decode(await meta.readAsString());
        } catch (_) {}
      }

      list.add({
        'file': dest.path.split(Platform.pathSeparator).last,
        'originalPath': srcPath,
        'timestamp': DateTime.now().toIso8601String(),
      });

      await meta.writeAsString(json.encode(list), flush: true);

      await _loadVideos();
    } catch (e) {
      debugPrint("Add video error: $e");
    }
  }

  /// ---------------- GET FILE EXTENSION ----------------
  String _extensionOf(String path) {
    final idx = path.lastIndexOf('.');
    if (idx == -1) return ".mp4";
    return path.substring(idx);
  }

  /// ---------------- GET VIDEO FILE ----------------
  Future<File?> _getVideo(String filename) async {
    final dir = await _appDir();
    final file =
        File('${dir.path}/vault_videos/$filename');

    if (await file.exists()) return file;
    return null;
  }

  /// ---------------- DELETE VIDEO ----------------
  Future<void> _deleteVideo(Map<String, dynamic> item) async {
    final dir = await _appDir();

    final meta =
        File('${dir.path}/${_FaceDetectionScreenState._vaultVideosFile}');

    if (await meta.exists()) {
      try {
        final list = json.decode(await meta.readAsString()) as List<dynamic>;
        list.removeWhere((e) => e["file"] == item["file"]);
        await meta.writeAsString(json.encode(list), flush: true);
      } catch (_) {}
    }

    final file = File('${dir.path}/vault_videos/${item["file"]}');
    if (await file.exists()) {
      await file.delete();
    }

    await _loadVideos();
  }

  /// ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vault Videos"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addVideo,
          ),
        ],
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())

          : _videos.isEmpty
              ? const Center(
                  child: Text(
                    "No videos added",
                    style: TextStyle(color: Colors.white70),
                  ),
                )

              : ListView.builder(
                  itemCount: _videos.length,
                  itemBuilder: (c, index) {
                    final item = _videos[index];
                    final fname = item["file"] ?? "";
                    final ts = item["timestamp"] ?? "";

                    return Card(
                      color: const Color(0xFF1B1B2F),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.videocam, color: Colors.white),

                        title: Text(
                          fname,
                          style: const TextStyle(color: Colors.white),
                        ),

                        subtitle: Text(
                          ts,
                          style: const TextStyle(color: Colors.white54),
                        ),

                        onTap: () async {
                          final file = await _getVideo(fname);

                          if (file == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("File not found")),
                            );
                            return;
                          }

                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Video Selected"),
                              content: Text("Stored at:\n${file.path}"),
                              actions: [
                                TextButton(
                                  child: const Text("OK"),
                                  onPressed: () => Navigator.pop(ctx),
                                ),
                              ],
                            ),
                          );
                        },

                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _deleteVideo(item),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
/// -------------------- Vault Documents Screen --------------------
class VaultDocumentsScreen extends StatefulWidget {
  const VaultDocumentsScreen({super.key});

  @override
  State<VaultDocumentsScreen> createState() => _VaultDocumentsScreenState();
}

class _VaultDocumentsScreenState extends State<VaultDocumentsScreen> {
  List<Map<String, dynamic>> _docs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDocs();
  }

  Future<Directory> _appDir() async =>
      await getApplicationDocumentsDirectory();

  /// ---------------- LOAD DOCUMENTS ----------------
  Future<void> _loadDocs() async {
    setState(() => _loading = true);

    final dir = await _appDir();
    final meta =
        File('${dir.path}/${_FaceDetectionScreenState._vaultDocsFile}');

    if (!await meta.exists()) {
      setState(() {
        _docs = [];
        _loading = false;
      });
      return;
    }

    try {
      final raw = json.decode(await meta.readAsString()) as List<dynamic>;

      setState(() {
        _docs =
            raw.map((e) => Map<String, dynamic>.from(e as Map)).toList().reversed.toList();
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _docs = [];
        _loading = false;
      });
    }
  }

  /// ---------------- ADD DOCUMENT ----------------
  Future<void> _addDocument() async {
    try {
      final picked = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ["pdf", "txt", "docx", "pptx"],
      );

      if (picked == null) return;

      final srcPath = picked.files.single.path;
      if (srcPath == null) return;

      final srcFile = File(srcPath);

      final dir = await _appDir();
      final folder = Directory('${dir.path}/vault_documents');

      if (!await folder.exists()) await folder.create(recursive: true);

      final ts = DateTime.now().millisecondsSinceEpoch;
      final extension = _ext(srcPath);

      final dest = File('${folder.path}/doc_$ts$extension');
      await srcFile.copy(dest.path);

      /// Save metadata
      final meta =
          File('${dir.path}/${_FaceDetectionScreenState._vaultDocsFile}');
      List list = [];

      if (await meta.exists()) {
        try {
          list = json.decode(await meta.readAsString());
        } catch (_) {}
      }

      list.add({
        'file': dest.path.split(Platform.pathSeparator).last,
        'originalPath': srcPath,
        'timestamp': DateTime.now().toIso8601String(),
      });

      await meta.writeAsString(json.encode(list), flush: true);

      await _loadDocs();
    } catch (e) {
      debugPrint("Add doc error: $e");
    }
  }

  String _ext(String p) {
    final i = p.lastIndexOf(".");
    if (i == -1) return ".pdf";
    return p.substring(i);
  }

  /// ---------------- DELETE DOCUMENT ----------------
  Future<void> _deleteDoc(Map<String, dynamic> item) async {
    final dir = await _appDir();

    final meta =
        File('${dir.path}/${_FaceDetectionScreenState._vaultDocsFile}');

    if (await meta.exists()) {
      try {
        final list = json.decode(await meta.readAsString()) as List<dynamic>;
        list.removeWhere((e) => e["file"] == item["file"]);
        await meta.writeAsString(json.encode(list), flush: true);
      } catch (_) {}
    }

    final file = File('${dir.path}/vault_documents/${item["file"]}');
    if (await file.exists()) await file.delete();

    await _loadDocs();
  }

  /// ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vault Documents"),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addDocument)
        ],
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _docs.isEmpty
              ? const Center(
                  child: Text(
                    "No documents added",
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  itemCount: _docs.length,
                  itemBuilder: (c, i) {
                    final doc = _docs[i];
                    final fname = doc["file"] ?? "";
                    final ts = doc["timestamp"] ?? "";

                    return Card(
                      color: const Color(0xFF1B1B2F),
                      margin:
                          const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: ListTile(
                        leading: const Icon(Icons.insert_drive_file,
                            color: Colors.white),

                        title: Text(
                          fname,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          ts,
                          style: const TextStyle(color: Colors.white54),
                        ),

                        onTap: () async {
                          final dir = await _appDir();
                          final f =
                              File('${dir.path}/vault_documents/$fname');

                          if (!await f.exists()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("File missing")),
                            );
                            return;
                          }

                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Document Info"),
                              content: Text("Path:\n${f.path}"),
                              actions: [
                                TextButton(
                                  child: const Text("OK"),
                                  onPressed: () => Navigator.pop(ctx),
                                )
                              ],
                            ),
                          );
                        },

                        trailing: IconButton(
                          icon:
                              const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _deleteDoc(doc),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
/// -------------------- Vault Audio Screen --------------------
class VaultAudioScreen extends StatefulWidget {
  const VaultAudioScreen({super.key});

  @override
  State<VaultAudioScreen> createState() => _VaultAudioScreenState();
}

class _VaultAudioScreenState extends State<VaultAudioScreen> {
  List<Map<String, dynamic>> _audio = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAudio();
  }

  Future<Directory> _appDir() async =>
      await getApplicationDocumentsDirectory();

  /// ---------------- LOAD AUDIO ----------------
  Future<void> _loadAudio() async {
    setState(() => _loading = true);

    final dir = await _appDir();
    final meta =
        File('${dir.path}/${_FaceDetectionScreenState._vaultAudioFile}');

    if (!await meta.exists()) {
      setState(() {
        _audio = [];
        _loading = false;
      });
      return;
    }

    try {
      final raw = json.decode(await meta.readAsString()) as List<dynamic>;

      setState(() {
        _audio =
            raw.map((e) => Map<String, dynamic>.from(e as Map)).toList().reversed.toList();
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _audio = [];
        _loading = false;
      });
    }
  }

  /// ---------------- ADD AUDIO FILE ----------------
  Future<void> _addAudio() async {
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (picked == null) return;

      final srcPath = picked.files.single.path;
      if (srcPath == null) return;

      final srcFile = File(srcPath);

      final dir = await _appDir();
      final folder = Directory('${dir.path}/vault_audio');

      if (!await folder.exists()) await folder.create(recursive: true);

      final ts = DateTime.now().millisecondsSinceEpoch;
      final ext = _ext(srcPath);

      final dest = File('${folder.path}/audio_$ts$ext');
      await srcFile.copy(dest.path);

      /// Save meta
      final meta =
          File('${dir.path}/${_FaceDetectionScreenState._vaultAudioFile}');
      List list = [];

      if (await meta.exists()) {
        try {
          list = json.decode(await meta.readAsString());
        } catch (_) {}
      }

      list.add({
        'file': dest.path.split(Platform.pathSeparator).last,
        'originalPath': srcPath,
        'timestamp': DateTime.now().toIso8601String()
      });

      await meta.writeAsString(json.encode(list), flush: true);

      await _loadAudio();
    } catch (e) {
      debugPrint("Add audio error: $e");
    }
  }

  String _ext(String p) {
    final i = p.lastIndexOf(".");
    if (i == -1) return ".mp3";
    return p.substring(i);
  }

  /// ---------------- DELETE AUDIO ----------------
  Future<void> _deleteAudio(Map<String, dynamic> item) async {
    final dir = await _appDir();

    final meta =
        File('${dir.path}/${_FaceDetectionScreenState._vaultAudioFile}');

    if (await meta.exists()) {
      try {
        final list = json.decode(await meta.readAsString()) as List<dynamic>;
        list.removeWhere((e) => e["file"] == item["file"]);
        await meta.writeAsString(json.encode(list), flush: true);
      } catch (_) {}
    }

    final file = File('${dir.path}/vault_audio/${item["file"]}');
    if (await file.exists()) await file.delete();

    await _loadAudio();
  }

  /// ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recordings"),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addAudio),
        ],
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _audio.isEmpty
              ? const Center(
                  child: Text(
                    "No recordings added",
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  itemCount: _audio.length,
                  itemBuilder: (c, i) {
                    final item = _audio[i];
                    final fname = item["file"] ?? "";
                    final ts = item["timestamp"] ?? "";

                    return Card(
                      color: const Color(0xFF1B1B2F),
                      margin:
                          const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: ListTile(
                        leading:
                            const Icon(Icons.audiotrack, color: Colors.white),

                        title: Text(
                          fname,
                          style: const TextStyle(color: Colors.white),
                        ),

                        subtitle: Text(
                          ts,
                          style: const TextStyle(color: Colors.white54),
                        ),

                        onTap: () async {
                          final dir = await _appDir();
                          final f =
                              File('${dir.path}/vault_audio/$fname');

                          if (!await f.exists()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Audio file missing")),
                            );
                            return;
                          }

                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Recording"),
                              content: Text("Path:\n${f.path}"),
                              actions: [
                                TextButton(
                                  child: const Text("OK"),
                                  onPressed: () => Navigator.pop(ctx),
                                )
                              ],
                            ),
                          );
                        },

                        trailing: IconButton(
                          icon:
                              const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _deleteAudio(item),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
/// -------------------- Vault Apps Screen --------------------
class VaultAppsScreen extends StatefulWidget {
  const VaultAppsScreen({super.key});

  @override
  State<VaultAppsScreen> createState() => _VaultAppsScreenState();
}

class _VaultAppsScreenState extends State<VaultAppsScreen> {
  List<Map<String, dynamic>> _apps = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<Directory> _appDir() async =>
      await getApplicationDocumentsDirectory();

  /// ---------------- LOAD APPS ----------------
  Future<void> _loadApps() async {
    setState(() => _loading = true);

    final dir = await _appDir();
    final meta =
        File('${dir.path}/${_FaceDetectionScreenState._vaultAppsFile}');

    if (!await meta.exists()) {
      setState(() {
        _apps = [];
        _loading = false;
      });
      return;
    }

    try {
      final raw = json.decode(await meta.readAsString()) as List<dynamic>;

      setState(() {
        _apps =
            raw.map((e) => Map<String, dynamic>.from(e as Map)).toList().reversed.toList();
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _apps = [];
        _loading = false;
      });
    }
  }

  /// ---------------- ADD APP (NAME + OPTIONAL PATH) ----------------
  Future<void> _addApp() async {
    final nameCtrl = TextEditingController();
    final pathCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add App"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "App Name"),
            ),
            TextField(
              controller: pathCtrl,
              decoration:
                  const InputDecoration(labelText: "Package/Path (optional)"),
            ),
          ],
        ),
        actions: [
          TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(ctx, false)),
          TextButton(
              child: const Text("Add"),
              onPressed: () => Navigator.pop(ctx, true)),
        ],
      ),
    );

    if (ok != true) return;

    final name = nameCtrl.text.trim();
    final meta = pathCtrl.text.trim();

    if (name.isEmpty) return;

    final dir = await _appDir();
    final file =
        File('${dir.path}/${_FaceDetectionScreenState._vaultAppsFile}');

    List list = [];

    if (await file.exists()) {
      try {
        list = json.decode(await file.readAsString());
      } catch (_) {}
    }

    list.add({
      'name': name,
      'meta': meta,
      'timestamp': DateTime.now().toIso8601String(),
    });

    await file.writeAsString(json.encode(list), flush: true);

    await _loadApps();
  }

  /// ---------------- DELETE APP ----------------
  Future<void> _delete(Map<String, dynamic> item) async {
    final dir = await _appDir();

    final meta =
        File('${dir.path}/${_FaceDetectionScreenState._vaultAppsFile}');

    if (await meta.exists()) {
      try {
        final list = json.decode(await meta.readAsString()) as List<dynamic>;
        list.removeWhere(
            (e) => e["name"] == item["name"] && e["meta"] == item["meta"]);
        await meta.writeAsString(json.encode(list), flush: true);
      } catch (_) {}
    }

    await _loadApps();
  }

  /// ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Apps"),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addApp)
        ],
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _apps.isEmpty
              ? const Center(
                  child: Text("No apps added",
                      style: TextStyle(color: Colors.white70)),
                )
              : ListView.builder(
                  itemCount: _apps.length,
                  itemBuilder: (c, i) {
                    final app = _apps[i];
                    final name = app["name"] ?? "";
                    final meta = app["meta"] ?? "";
                    final ts = app["timestamp"] ?? "";

                    return Card(
                      color: const Color(0xFF1B1B2F),
                      margin:
                          const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: ListTile(
                        leading: const Icon(Icons.apps, color: Colors.white),

                        title: Text(
                          name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          meta.isNotEmpty ? meta : ts,
                          style: const TextStyle(color: Colors.white54),
                        ),

                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(name),
                              content: Text(
                                  "Package/Path:\n$meta\n\nAdded:\n$ts"),
                              actions: [
                                TextButton(
                                  child: const Text("OK"),
                                  onPressed: () => Navigator.pop(ctx),
                                )
                              ],
                            ),
                          );
                        },

                        trailing: IconButton(
                          icon:
                              const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _delete(app),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
