import 'package:flutter/material.dart';
import '../services/pin_lock_service.dart';

class PinLockScreen extends StatefulWidget {
  /// isSetup = true → create PIN (first install)
  /// isSetup = false → unlock using PIN
  final bool isSetup;

  const PinLockScreen({super.key, this.isSetup = false});

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

    if (widget.isSetup) {
      /// 🔐 SAVE PIN
      await PinLockService.savePin(pin);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      /// 🔓 VERIFY PIN
      final ok = await PinLockService.verifyPin(pin);

      if (ok) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, "/vault");
      } else {
        setState(() => error = "Incorrect PIN");
      }
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
      appBar: AppBar(
        title: Text(widget.isSetup ? "Set PIN" : "Enter PIN"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 80,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 20),

            Text(
              widget.isSetup
                  ? "Create a 4-digit PIN"
                  : "Enter your 4-digit PIN",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "PIN",
                errorText: error.isEmpty ? null : error,
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handlePin,
                child: Text(widget.isSetup ? "Save PIN" : "Unlock"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
