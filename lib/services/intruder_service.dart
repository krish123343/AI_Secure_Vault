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

    // Create folder if not exist
    if (!await intruderDir.exists()) {
      await intruderDir.create(recursive: true);
    }

    // Save intruder image
    final fileName = "intruder_${DateTime.now().millisecondsSinceEpoch}.jpg";
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
}
