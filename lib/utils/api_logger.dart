import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Debug-only API logging with recursive redaction.
class ApiLogger {
  static const Set<String> _sensitiveKeys = {
    'authorization',
    'cookie',
    'set_cookie',
    'password',
    'pass',
    'token',
    'access_token',
    'refresh_token',
    'firebase_custom_token',
    'firebase_token',
    'fcm_token',
    'jwt',
    'secret',
    'api_key',
    'apikey',
    'session',
    'session_id',
    'code',
    'qr',
    'qr_code',
    'email',
    'phone',
    'mobile',
    'employee_id',
    'emp_id',
    'odoo_user_id',
    'user_id',
    'uid',
    'lpi',
    'lpi_number',
  };

  static const int _maxStringLength = 512;
  static const int _maxIterableItems = 30;
  static const int _maxMapEntries = 60;

  static void logRequest({
    required String endpoint,
    required String method,
    Map<String, dynamic>? headers,
    dynamic body,
  }) {
    if (!kDebugMode) return;

    final log = StringBuffer()
      ..writeln('')
      ..writeln('API REQUEST')
      ..writeln('Method: $method')
      ..writeln('Endpoint: ${_redactUrl(endpoint)}');

    if (headers != null && headers.isNotEmpty) {
      log
        ..writeln('Headers:')
        ..writeln(_pretty(_sanitizeForLog(headers)));
    }

    if (body != null) {
      log
        ..writeln('Body:')
        ..writeln(_pretty(_sanitizeForLog(body)));
    }

    _emit(log.toString());
  }

  static void logResponse({
    required String endpoint,
    required int statusCode,
    dynamic responseBody,
    Duration? duration,
  }) {
    if (!kDebugMode) return;

    final log = StringBuffer()
      ..writeln('')
      ..writeln('API RESPONSE')
      ..writeln('Endpoint: ${_redactUrl(endpoint)}')
      ..writeln('Status Code: $statusCode');

    if (duration != null) {
      log.writeln('Duration: ${duration.inMilliseconds}ms');
    }

    if (responseBody != null) {
      log
        ..writeln('Response Body:')
        ..writeln(_pretty(_sanitizeForLog(responseBody)));
    }

    _emit(log.toString());
  }

  static void logError({
    required String endpoint,
    required dynamic error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;

    final log = StringBuffer()
      ..writeln('')
      ..writeln('API ERROR')
      ..writeln('Endpoint: ${_redactUrl(endpoint)}')
      ..writeln('Error: ${_sanitizeScalar(error)}');

    if (stackTrace != null) {
      log.writeln('Stack Trace:');
      for (final line in stackTrace.toString().split('\n').take(5)) {
        log.writeln(line);
      }
    }

    _emit(log.toString(), error: error, stackTrace: stackTrace);
  }

  static void log(String message) {
    if (!kDebugMode) return;
    _emit(_sanitizeScalar(message).toString());
  }

  @visibleForTesting
  static Object? sanitizeForTesting(Object? value) => _sanitizeForLog(value);

  @visibleForTesting
  static String redactUrlForTesting(String value) => _redactUrl(value);

  static Object? _sanitizeForLog(Object? value, {String? key}) {
    if (_isSensitiveKey(key)) return '<redacted>';
    if (value == null || value is num || value is bool) return value;
    if (value is String) return _sanitizeScalar(value);

    if (value is Map) {
      final sanitized = <String, Object?>{};
      var count = 0;
      for (final entry in value.entries) {
        if (count >= _maxMapEntries) {
          sanitized['...'] = '<truncated>';
          break;
        }
        final entryKey = entry.key.toString();
        sanitized[entryKey] = _sanitizeForLog(entry.value, key: entryKey);
        count++;
      }
      return sanitized;
    }

    if (value is Iterable) {
      final sanitized = <Object?>[];
      var count = 0;
      for (final item in value) {
        if (count >= _maxIterableItems) {
          sanitized.add('<truncated>');
          break;
        }
        sanitized.add(_sanitizeForLog(item));
        count++;
      }
      return sanitized;
    }

    return _sanitizeScalar(value);
  }

  static Object _sanitizeScalar(Object value) {
    final text = _safeLogText(value.toString());
    final redacted = text
        .replaceAll(
          RegExp(r'Bearer\s+[A-Za-z0-9._~+/=-]+', caseSensitive: false),
          'Bearer <redacted>',
        )
        .replaceAllMapped(
          RegExp(
            r'([?&](?:token|access_token|refresh_token|session|code|qr|jwt|api_key)=)[^&\s]+',
            caseSensitive: false,
          ),
          (match) => '${match.group(1)}<redacted>',
        );

    if (redacted.length <= _maxStringLength) return redacted;
    return '${redacted.substring(0, _maxStringLength)}...<truncated>';
  }

  static bool _isSensitiveKey(String? key) {
    if (key == null) return false;
    final normalized = key.trim().toLowerCase().replaceAll('-', '_');
    return _sensitiveKeys.contains(normalized) ||
        normalized.contains('password') ||
        normalized.endsWith('_token') ||
        normalized.contains('secret') ||
        normalized.contains('password') ||
        normalized.contains('employee_id') ||
        normalized.contains('phone') ||
        normalized.contains('mobile');
  }

  static String _redactUrl(String endpoint) {
    final safe = _sanitizeScalar(endpoint).toString();
    try {
      final uri = Uri.parse(safe);
      if (!uri.hasQuery) return safe;
      final params = Map<String, String>.from(uri.queryParameters);
      params.updateAll((key, value) {
        if (_isSensitiveKey(key)) return '<redacted>';
        return _sanitizeScalar(value).toString();
      });
      return uri.replace(queryParameters: params).toString();
    } catch (_) {
      return safe;
    }
  }

  static String _pretty(Object? value) {
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return _sanitizeScalar(value ?? '<null>').toString();
    }
  }

  static String _safeLogText(String input) {
    final buf = StringBuffer();
    for (final unit in input.runes) {
      if (unit == 0xFFFD || (unit >= 0xD800 && unit <= 0xDFFF)) {
        buf.write('?');
      } else {
        buf.writeCharCode(unit);
      }
    }
    return buf.toString();
  }

  static void _emit(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    final safe = _safeLogText(message);
    developer.log(
      safe,
      name: 'API',
      error: error,
      stackTrace: stackTrace,
    );
    debugPrint(safe, wrapWidth: 1000);
  }
}
