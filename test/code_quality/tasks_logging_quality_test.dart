import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const checkedFiles = [
    'lib/ui/presentation/tasks/bloc/tasks_bloc.dart',
    'lib/ui/presentation/tasks/data/local_tasks_hive_service.dart',
    'lib/utils/Util.dart',
    'lib/utils/di.dart',
  ];

  test('tasks and utility cleanup surface has no direct print calls', () {
    for (final path in checkedFiles) {
      final content = File(path).readAsStringSync();

      expect(
        content,
        isNot(contains(RegExp(r'(^|[^A-Za-z_])print\('))),
        reason: '$path should use AppLogger instead of direct print.',
      );
    }
  });

  test('tasks and utility cleanup surface has no empty catch blocks', () {
    final emptyCatchPattern = RegExp(r'catch\s*\([^)]*\)\s*\{\s*\}');

    for (final path in checkedFiles) {
      final content = File(path).readAsStringSync();

      expect(
        content,
        isNot(contains(emptyCatchPattern)),
        reason: '$path should log or handle caught errors explicitly.',
      );
    }
  });
}
