import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Project compliance guards', () {
    test('does not request or use Android exact alarm scheduling', () {
      final files = _projectFiles([
        'lib',
        'android'
      ], {
        '.dart',
        '.kt',
        '.java',
        '.xml',
      });

      const forbidden = [
        'requestExactAlarmsPermission',
        'Permission.scheduleExactAlarm.request',
        'ACTION_REQUEST_SCHEDULE_EXACT_ALARM',
        'AndroidScheduleMode.exactAllowWhileIdle',
      ];

      for (final file in files) {
        final text = file.readAsStringSync();
        for (final token in forbidden) {
          expect(
            text,
            isNot(contains(token)),
            reason: '${file.path} must not contain $token',
          );
        }
      }
    });

    test('keeps removed duplicate/heavy assets out of the app bundle', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      const removedAssets = [
        'assets/mobilefacenet.tflite',
        'assets/json/logo.json',
        'assets/png/pettycash_new_bg_old2.png',
        'assets/newapp/test_petty_cach_image.png',
        'assets/newapp/company_document_tab_folder.svg',
      ];

      for (final asset in removedAssets) {
        expect(File(asset).existsSync(), isFalse, reason: asset);
        expect(pubspec, isNot(contains(asset)), reason: asset);
      }
      expect(pubspec, contains('assets/mobilefacenet_512.tflite'));
    });

    test('keeps sensitive chat auth/session files free of direct prints', () {
      const sensitiveFiles = [
        'lib/chat/models/chat_user_session.dart',
        'lib/chat/services/firebase_token_api_service.dart',
        'lib/chat/services/firebase_chat_auth_service.dart',
      ];

      for (final path in sensitiveFiles) {
        final text = File(path).readAsStringSync();
        expect(text, isNot(contains('print(')), reason: path);
      }
    });

    test('does not print push tokens or cached chat identifiers', () {
      final main = File('lib/main.dart').readAsStringSync();
      final firebaseService =
          File('lib/firebase_service.dart').readAsStringSync();
      final chatSessionStorage =
          File('lib/chat/services/chat_session_storage.dart')
              .readAsStringSync();

      expect(main, isNot(contains('print(fcmToken)')));
      expect(main, isNot(contains('FCM TOKEN')));
      expect(firebaseService, isNot(contains('token.substring(0, 20)')));
      expect(firebaseService, isNot(contains('apnsToken.substring(0, 20)')));
      expect(chatSessionStorage, isNot(contains('Firebase UID:')));
      expect(chatSessionStorage, isNot(contains('Role Chat ID:')));
    });
  });
}

Iterable<File> _projectFiles(
  List<String> roots,
  Set<String> extensions,
) sync* {
  for (final root in roots) {
    final directory = Directory(root);
    if (!directory.existsSync()) continue;

    yield* directory
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => extensions.contains(_extension(file.path)));
  }
}

String _extension(String path) {
  final index = path.lastIndexOf('.');
  if (index == -1) return '';
  return path.substring(index).toLowerCase();
}
