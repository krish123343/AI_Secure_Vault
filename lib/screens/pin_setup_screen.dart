import 'package:flutter/material.dart';
import '../services/pin_lock_service.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final pin1 = TextEditingController();
  final pin2 = TextEditingController();
  String error = "";

  Future<void> save() async {
    if (pin1.text.length != 4) {
      setState(() => error = "PIN must be 4 digits");
      return;
    }

    if (pin1.text != pin2.text) {
      setState(() => error = "PINs do not match!");
      return;
    }

    await PinLockService.savePin(pin1.text);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, "/vault");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Set PIN")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: pin1,
              obscureText: true,
              maxLength: 4,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Enter PIN"),
            ),
            TextField(
              controller: pin2,
              obscureText: true,
              maxLength: 4,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Confirm PIN"),
            ),
            if (error.isNotEmpty)
              Text(error, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: save,
              child: const Text("Save PIN"),
            ),
          ],
        ),
      ),
    );
  }
}
