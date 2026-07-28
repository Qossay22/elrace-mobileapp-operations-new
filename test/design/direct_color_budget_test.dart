import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps direct color usage from growing outside theme files', () {
    final directColorPattern = RegExp(r'(?:const\s+)?Color\(0x|Colors\.');
    var count = 0;

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;

      final normalized = entity.path.replaceAll('\\', '/').toLowerCase();
      final isThemeOrColorFile = normalized.contains('/theme/') ||
          normalized.endsWith('/colors.dart') ||
          normalized.endsWith('/app_colors.dart') ||
          normalized.contains('theme.dart') ||
          normalized.contains('_theme.dart');
      if (isThemeOrColorFile) continue;

      count += directColorPattern.allMatches(entity.readAsStringSync()).length;
    }

    expect(
      count,
      lessThanOrEqualTo(7703),
      reason:
          'Move new colors into existing theme/token files instead of adding direct Color/Colors usage.',
    );
  });
}
