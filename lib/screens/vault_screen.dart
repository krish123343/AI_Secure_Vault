// 📌 lib/screens/vault_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';

import '../services/vault_storage_service.dart';
import '../services/vault_encryption_service.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen>
    with WidgetsBindingObserver {
  List<FileSystemEntity> files = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadVaultFiles();
  }

  // --------------------------------------------------------------
  // 🔐 AUTO-LOCK VAULT WHEN APP GOES BACKGROUND
  // --------------------------------------------------------------
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, "/home");
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // --------------------------------------------------------------
  // 📂 LOAD ENCRYPTED FILES
  // --------------------------------------------------------------
  Future<void> _loadVaultFiles() async {
    final all = await VaultStorageService.loadAll();
    setState(() => files = all);
  }

  // --------------------------------------------------------------
  // 🔓 OPEN ENCRYPTED FILE & PREVIEW
  // --------------------------------------------------------------
  Future<void> openEncryptedFile(File file) async {
    final temp = await VaultEncryptionService.decryptFile(file);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text("Preview"),
          ),
          body: Center(child: Image.file(temp)),
        ),
      ),
    );
  }

  // --------------------------------------------------------------
  // 🗑 DELETE ENCRYPTED FILE
  // --------------------------------------------------------------
  Future<void> deleteFile(String fileName) async {
    await VaultStorageService.delete(fileName);
    await _loadVaultFiles();
  }

  // --------------------------------------------------------------
  // UI DESIGN
  // --------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0C1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Vault',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadVaultFiles,
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: files.isEmpty
            ? const Center(
                child: Text(
                  "No encrypted files yet",
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              )
            : GridView.builder(
                itemCount: files.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final file = files[index] as File;

                  return GestureDetector(
                    onTap: () => openEncryptedFile(file),
                    onLongPress: () =>
                        deleteFile(file.path.split('/').last),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B1B2F),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.lock,
                            color: Colors.white, size: 42),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
