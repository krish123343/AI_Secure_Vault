import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailAlertService {
  // 🔐 Gmail credentials (USE APP PASSWORD ONLY)
  static const String senderEmail = "yourmail@gmail.com";
  static const String appPassword = "YOUR_16_DIGIT_APP_PASSWORD";
  static const String receiverEmail = "yourmail@gmail.com";

  /// 🚨 SEND INTRUDER ALERT EMAIL (NEW API)
  static Future<void> sendIntruderEmail(
    File intruderImage,
    String timestamp,
  ) async {
    final smtpServer = gmail(senderEmail, appPassword);

    final message = Message()
      ..from = Address(senderEmail, "AI Secure Access")
      ..recipients.add(receiverEmail)
      ..subject = "🚨 Intruder Detected — $timestamp"
      ..text = '''
⚠️ INTRUDER ALERT!

An unauthorized face was detected on your device.

🕒 Time: $timestamp

Please review the attached image immediately.
'''
      ..attachments = [
        FileAttachment(intruderImage),
      ];

    try {
      await send(message, smtpServer);
      // ignore: avoid_print
      print("✅ Intruder alert email sent");
    } catch (e) {
      // ignore: avoid_print
      print("❌ Failed to send intruder email: $e");
    }
  }
}
