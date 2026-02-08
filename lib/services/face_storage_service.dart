import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class FaceStorageService {
  /// 🔑 Keys
  static const String _registeredKey = "face_registered";
  static const String _embeddingKey = "face_embedding";

  // --------------------------------------------------
  // ✅ CHECK IF FACE IS REGISTERED
  // --------------------------------------------------
  static Future<bool> isFaceRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_registeredKey) ?? false;
  }

  // --------------------------------------------------
  // 💾 SAVE FACE EMBEDDING (REGISTER)
  // --------------------------------------------------
  static Future<void> saveEmbedding(List<double> embedding) async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = jsonEncode(embedding);
    await prefs.setString(_embeddingKey, encoded);
    await prefs.setBool(_registeredKey, true);
  }

  // --------------------------------------------------
  // 📥 LOAD REGISTERED FACE EMBEDDING
  // --------------------------------------------------
  static Future<List<double>?> loadEmbedding() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_embeddingKey);

    if (encoded == null) return null;

    final List decoded = jsonDecode(encoded);
    return decoded.map((e) => (e as num).toDouble()).toList();
  }

  // --------------------------------------------------
  // ❌ CLEAR REGISTERED FACE (RESET)
  // --------------------------------------------------
  static Future<void> clearFace() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_registeredKey);
    await prefs.remove(_embeddingKey);
  }
}
