import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ai_secure_access/constants/app_colors.dart';
import '../services/vault_storage_service.dart';
import '../services/vault_encryption_service.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> with WidgetsBindingObserver {
  List<FileSystemEntity> files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadVaultFiles();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
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

  Future<void> _loadVaultFiles() async {
    setState(() => _isLoading = true);
    final all = await VaultStorageService.loadAll();
    if (mounted) {
      setState(() {
        files = all;
        _isLoading = false;
      });
    }
  }

  Future<void> _openEncryptedFile(File file) async {
    final temp = await VaultEncryptionService.decryptFile(file);
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text("Preview"),
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(child: Image.file(temp)),
        ),
      ),
    );

    if (await temp.exists()) {
      await temp.delete();
    }
  }

  Future<void> _deleteFile(String fileName) async {
    await VaultStorageService.delete(fileName);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("File deleted successfully")),
    );
    _loadVaultFiles();
  }

  void _showDeleteConfirmation(String fileName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete File"),
        content: const Text("Are you sure you want to delete this file?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteFile(fileName);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: const Text(
          'Secure Vault',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadVaultFiles,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: files.isEmpty
                  ? _buildEmptyVaultView()
                  : _buildFileGridView(),
            ),
    );
  }

  Widget _buildEmptyVaultView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.security, color: Colors.grey, size: 80),
          const SizedBox(height: 20),
          const Text(
            "Your vault is empty",
            style: TextStyle(color: Colors.grey, fontSize: 18),
          ),
          const SizedBox(height: 10),
          const Text(
            "Add files to your vault to keep them secure.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildFileGridView() {
    return GridView.builder(
      itemCount: files.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final file = files[index] as File;
        final fileName = file.path.split('/').last;

        return GestureDetector(
          onTap: () => _openEncryptedFile(file),
          onLongPress: () => _showDeleteConfirmation(fileName),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha((255 * 0.2).round()),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, color: AppColors.primary, size: 42),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    fileName,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
