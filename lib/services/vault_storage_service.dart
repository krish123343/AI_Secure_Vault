import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:encrypt/encrypt.dart' as enc;

class VaultStorageService {
  // 32-char AES key (do NOT change length)
  static const String _keyString = "32charsecretkeyforvault123456";
  static final enc.Key _key = enc.Key.fromUtf8(_keyString);
  static final enc.IV _iv = enc.IV.fromLength(16);

  static final encrypter = enc.Encrypter(
    enc.AES(
      _key,
      mode: enc.AESMode.cbc,      // safer mode
      padding: 'PKCS7',
    ),
  );

  /// ---------------------------------------------------------
  /// GET / CREATE VAULT DIRECTORY
  /// ---------------------------------------------------------
  static Future<Directory> getVaultDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final vaultDir = Directory("${dir.path}/vault");

    if (!await vaultDir.exists()) {
      await vaultDir.create(recursive: true);
    }

    return vaultDir;
  }

  /// ---------------------------------------------------------
  /// ENCRYPT & SAVE FILE IN VAULT
  /// ---------------------------------------------------------
  static Future<File> saveEncryptedFile(List<int> bytes, String fileName) async {
    final encrypted = encrypter.encryptBytes(bytes, iv: _iv);

    final dir = await getVaultDir();
    final file = File("${dir.path}/$fileName.enc");

    await file.writeAsBytes(encrypted.bytes, flush: true);
    return file;
  }

  /// ---------------------------------------------------------
  /// DECRYPT FILE (FOR VIEW / OPEN)
  /// ---------------------------------------------------------
  static Future<List<int>> loadDecryptedFile(String fileName) async {
    final dir = await getVaultDir();
    final file = File("${dir.path}/$fileName");

    if (!await file.exists()) return [];

    final encryptedBytes = await file.readAsBytes();

    final decrypted = encrypter.decryptBytes(
      enc.Encrypted(encryptedBytes),
      iv: _iv,
    );

    return decrypted;
  }

  /// ---------------------------------------------------------
  /// LIST ALL ENCRYPTED FILES (.enc)
  /// ---------------------------------------------------------
  static Future<List<FileSystemEntity>> loadAll() async {
    final dir = await getVaultDir();
    return dir.listSync().where((file) {
      return file.path.endsWith(".enc");  // only encrypted files
    }).toList();
  }

  /// ---------------------------------------------------------
  /// DELETE FILE
  /// ---------------------------------------------------------
  static Future<void> delete(String fileName) async {
    final dir = await getVaultDir();
    final file = File("${dir.path}/$fileName");

    if (await file.exists()) {
      await file.delete();
    }
  }
}
