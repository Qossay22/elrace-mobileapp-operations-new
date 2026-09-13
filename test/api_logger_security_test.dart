import 'dart:convert';

import 'package:el_race/utils/api_logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiLogger redaction', () {
    test('redacts sensitive headers and nested payload fields', () {
      final sanitized = ApiLogger.sanitizeForTesting({
        'Authorization': 'Bearer real.jwt.token',
        'Content-Type': 'application/json',
        'params': {
          'password': 'secret-password',
          'firebase_custom_token': 'firebase-secret',
          'profile': {
            'name': 'Visible Name',
            'email': 'person@example.com',
            'employee_id': 42,
            'fcm_token': 'device-token',
          },
          'lpi_number': 'LPI-2026-001',
        },
      });

      final text = jsonEncode(sanitized);

      expect(text, isNot(contains('real.jwt.token')));
      expect(text, isNot(contains('secret-password')));
      expect(text, isNot(contains('firebase-secret')));
      expect(text, isNot(contains('device-token')));
      expect(text, isNot(contains('person@example.com')));
      expect(text, isNot(contains('LPI-2026-001')));
      expect(text, contains('Visible Name'));
      expect(text, contains('<redacted>'));
    });

    test('redacts sensitive query parameters from URLs', () {
      final redacted = ApiLogger.redactUrlForTesting(
        'https://erp.elrace.com/api/login?token=abc123&code=qr-secret&page=1',
      );

      expect(redacted, isNot(contains('abc123')));
      expect(redacted, isNot(contains('qr-secret')));
      expect(redacted, contains('page=1'));
      expect(redacted, contains('%3Credacted%3E'));
    });

    test('truncates long non-sensitive strings', () {
      final sanitized = ApiLogger.sanitizeForTesting('x' * 700);

      expect(sanitized.toString().length, lessThan(550));
      expect(sanitized, contains('<truncated>'));
    });
  });
}
