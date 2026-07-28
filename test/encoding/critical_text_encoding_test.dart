import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const checkedPaths = [
    'lib/main.dart',
    'pubspec.yaml',
    'firebase.json',
    'firestore.rules',
    'functions/package.json',
    'functions-liveness/package.json',
    'assets/i18n/ar.json',
    'assets/i18n/en.json',
  ];

  test('critical text/config files do not contain common mojibake markers', () {
    final mojibakePattern = RegExp(r'[ØÙÃÂ�]');

    for (final path in checkedPaths) {
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: '$path should exist.');

      final content = file.readAsStringSync();
      expect(
        content,
        isNot(contains(mojibakePattern)),
        reason: '$path contains common mojibake or replacement characters.',
      );
    }
  });
}
