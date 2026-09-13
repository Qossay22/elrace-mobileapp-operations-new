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
      final duplicateModel = File('assets/mobilefacenet.tflite');
      final unusedLogoJson = File('assets/json/logo.json');
      final pubspec = File('pubspec.yaml').readAsStringSync();

      expect(duplicateModel.existsSync(), isFalse);
      expect(unusedLogoJson.existsSync(), isFalse);
      expect(pubspec, contains('assets/mobilefacenet_512.tflite'));
      expect(pubspec, isNot(contains('assets/mobilefacenet.tflite')));
      expect(pubspec, isNot(contains('assets/json/logo.json')));
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
