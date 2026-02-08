import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class IntruderService {
  static const String _folderName = "intruders";
  static const String _logFile = "intruder_logs.json";

  /// SAVE INTRUDER IMAGE + LOG
  static Future<void> saveIntruder(File imageFile) async {
    final dir = await getApplicationDocumentsDirectory();
    final intruderDir = Directory("${dir.path}/$_folderName");

    // Create folder if not exists
    if (!await intruderDir.exists()) {
      await intruderDir.create(recursive: true);
    }

    // Save intruder image
    final fileName =
        "intruder_${DateTime.now().millisecondsSinceEpoch}.jpg";
    final savedImage = File("${intruderDir.path}/$fileName");

    await savedImage.writeAsBytes(await imageFile.readAsBytes());

    // Write log
    final logFile = File("${dir.path}/$_logFile");
    List logs = [];

    if (await logFile.exists()) {
      logs = jsonDecode(await logFile.readAsString());
    }

    logs.add({
      "file": fileName,
      "time": DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()),
    });

    await logFile.writeAsString(jsonEncode(logs));
  }

  /// LOAD LOGS (needed by IntruderListScreen)
  static Future<List<Map<String, dynamic>>> loadLogs() async {
    final dir = await getApplicationDocumentsDirectory();
    final logFile = File("${dir.path}/$_logFile");

    if (!await logFile.exists()) return [];

    final List raw = jsonDecode(await logFile.readAsString());

    // Convert file name → full path
    return raw.map<Map<String, dynamic>>((entry) {
      return {
        "path": "${dir.path}/$_folderName/${entry["file"]}",
        "time": entry["time"],
      };
    }).toList();
  }
}
