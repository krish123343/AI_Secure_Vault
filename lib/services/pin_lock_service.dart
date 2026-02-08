import 'package:shared_preferences/shared_preferences.dart';

class PinLockService {
  static const String _pinKey = "vault_pin";

  /// Save a new PIN
  static Future<void> savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, pin);
  }

  /// Verify PIN
  static Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_pinKey);
    return saved == pin;
  }

  /// Check if PIN is already set
  static Future<bool> isPinSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_pinKey);
  }
}
