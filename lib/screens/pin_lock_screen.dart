
import 'package:ai_secure_access/constants/app_colors.dart';
import 'package:flutter/material.dart';
import '../services/pin_lock_service.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final TextEditingController _controller = TextEditingController();
  String error = "";

  Future<void> _handlePin() async {
    final pin = _controller.text.trim();

    if (pin.length != 4) {
      setState(() => error = "PIN must be 4 digits");
      return;
    }

    final ok = await PinLockService.verifyPin(pin);

    if (ok) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/vault");
    } else {
      setState(() => error = "Incorrect PIN");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: const Text(
          "Enter PIN",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: 20),
            const Text(
              "Enter your 4-digit PIN to unlock the vault.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            _buildPinField(_controller, "Enter PIN"),
            const SizedBox(height: 20),
            if (error.isNotEmpty)
              Text(
                error,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _handlePin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Unlock",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinField(TextEditingController controller, String label) {
    return SizedBox(
      width: 200,
      child: TextField(
        controller: controller,
        obscureText: true,
        maxLength: 4,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: label,
          counterText: "", // Hide the counter
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}
