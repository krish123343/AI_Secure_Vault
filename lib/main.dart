import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_screen.dart';
import 'screens/face_detection_screen.dart';
import 'screens/vault_screen.dart';
import 'screens/pin_lock_screen.dart';
import 'screens/pin_setup_screen.dart'; // <-- IMPORTANT

/// 🌍 Global cameras list
List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const AISecureAccessApp());
}

/// ------------------------------------------------------
/// ROOT APP
/// ------------------------------------------------------
class AISecureAccessApp extends StatelessWidget {
  const AISecureAccessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "AI Secure Access",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),

      /// 🔁 ROUTES
      routes: {
        "/home": (_) => const HomeScreen(),
        "/face": (_) => const FaceDetectionScreen(),
        "/vault": (_) => const VaultScreen(),

        /// 🔐 PIN ROUTES
        "/pin": (_) => const PinLockScreen(),
        "/pin-setup": (_) => const PinSetupScreen(),
      },

      home: const LaunchHandler(),
    );
  }
}

/// ------------------------------------------------------
/// DECIDES FIRST SCREEN
/// ------------------------------------------------------
class LaunchHandler extends StatefulWidget {
  const LaunchHandler({super.key});

  @override
  State<LaunchHandler> createState() => _LaunchHandlerState();
}

class _LaunchHandlerState extends State<LaunchHandler> {
  bool? faceRegistered;
  bool? pinSet;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final prefs = await SharedPreferences.getInstance();

    faceRegistered = prefs.getBool("face_registered") ?? false;
    pinSet = prefs.getBool("pin_set") ?? false;

    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (faceRegistered == null || pinSet == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    /// 1️⃣ FIRST INSTALL → SET PIN
    if (pinSet == false) {
      return const PinSetupScreen();
    }

    /// 2️⃣ FACE NOT REGISTERED → REGISTER FACE
    if (faceRegistered == false) {
      return const FaceDetectionScreen();
    }

    /// 3️⃣ NORMAL FLOW → HOME SCREEN
    return const HomeScreen();
  }
}
