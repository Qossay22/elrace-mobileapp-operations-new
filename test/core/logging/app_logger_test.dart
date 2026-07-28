import 'package:el_race/core/logging/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DebugPrintCallback originalDebugPrint;
  late List<String?> lines;

  setUp(() {
    originalDebugPrint = debugPrint;
    lines = <String?>[];
    debugPrint = (String? message, {int? wrapWidth}) {
      lines.add(message);
    };
  });

  tearDown(() {
    debugPrint = originalDebugPrint;
  });

  test('masks sensitive structured values while keeping useful context', () {
    AppLogger.debug(
      'API request',
      data: {
        'endpoint': 'https://erp.elrace.com/api/get_user_tasks',
        'authorization': 'Bearer abcdefghijklmnopqrstuvwxyz',
        'fcm_token': 'fcm-token-value-1234567890',
        'apns_token': 'apns-token-value-1234567890',
        'password': 'secret-password',
      },
    );

    final output = lines.join('\n');

    expect(output, contains('https://erp.elrace.com/api/get_user_tasks'));
    expect(output, contains('Bear...wxyz'));
    expect(output, contains('fcm-...7890'));
    expect(output, contains('apns...7890'));
    expect(output, contains('secr...word'));
    expect(output, isNot(contains('Bearer abcdefghijklmnopqrstuvwxyz')));
    expect(output, isNot(contains('fcm-token-value-1234567890')));
    expect(output, isNot(contains('apns-token-value-1234567890')));
    expect(output, isNot(contains('secret-password')));
  });

  test('masks JWT-like strings but does not mask normal dotted URLs', () {
    const jwt = 'header123.payload456.signature789';
    const url = 'https://erp.elrace.com/api/v2/clients/list';

    AppLogger.debug('Token check', data: {'token': jwt, 'url': url});

    final output = lines.join('\n');

    expect(output, contains('head...e789'));
    expect(output, contains(url));
    expect(output, isNot(contains(jwt)));
  });
}
