// 📌 lib/services/vault_encryption_service.dart

import 'dart:io';
import 'package:encrypt/encrypt.dart';
import 'package:path_provider/path_provider.dart';

class VaultEncryptionService {
  // 🔐 32-byte AES-256 key (must always be exactly 32 chars)
  static final Key _key = Key.fromUtf8('32charsecretkeyforvault123456');

  // 🔐 AES requires a 16-byte IV
  static final IV _iv = IV.fromLength(16);

  static final Encrypter _encrypter = Encrypter(AES(_key));

  // -------------------------------------------------------------
  // 🔒 ENCRYPT FILE → Save inside VAULT folder as .vault file
  // -------------------------------------------------------------
  static Future<File> encryptFile(File file, Directory vaultDir) async {
    final bytes = await file.readAsBytes();

    final encrypted = _encrypter.encryptBytes(bytes, iv: _iv);

    final encryptedFile = File(
      '${vaultDir.path}/${DateTime.now().millisecondsSinceEpoch}.vault',
    );

    await encryptedFile.writeAsBytes(encrypted.bytes, flush: true);

    // Delete original unencrypted file for security
    await file.delete();

    return encryptedFile;
  }

  // -------------------------------------------------------------
  // 🔓 DECRYPT FILE → Returns a TEMPORARY JPEG for preview
  // -------------------------------------------------------------
  static Future<File> decryptFile(File encryptedFile) async {
    final encryptedBytes = await encryptedFile.readAsBytes();

    final decrypted = _encrypter.decryptBytes(
      Encrypted(encryptedBytes),
      iv: _iv,
    );

    final tempDir = await getTemporaryDirectory();

    final tempFile = File(
      '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    await tempFile.writeAsBytes(decrypted, flush: true);

    return tempFile;
  }
}
