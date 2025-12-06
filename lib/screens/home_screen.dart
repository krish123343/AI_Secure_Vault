import 'package:flutter/material.dart';
import 'face_detection_screen.dart';
import 'vault_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),

      appBar: AppBar(
        title: const Text("AI Secure Access"),
        backgroundColor: Colors.black,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            _menuButton(
              icon: Icons.face,
              title: "Face Unlock",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FaceDetectionScreen()),
              ),
            ),

            const SizedBox(height: 20),

            _menuButton(
              icon: Icons.lock,
              title: "Your Vault",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VaultScreen()),
              ),
            ),

            const SizedBox(height: 20),

            _menuButton(
              icon: Icons.settings,
              title: "Settings",
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuButton({
    required IconData icon,
    required String title,
    required Function() onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),

      child: Container(
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.3),
              blurRadius: 12,
            )
          ],
        ),

        child: Row(
          children: [
            const SizedBox(width: 20),

            Icon(icon, color: Colors.blueAccent, size: 32),

            const SizedBox(width: 20),

            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),

            const Spacer(),

            const Icon(Icons.arrow_forward_ios, color: Colors.white70),

            const SizedBox(width: 15),
          ],
        ),
      ),
    );
  }
}
