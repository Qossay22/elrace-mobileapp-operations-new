import 'dart:convert';

import 'package:flutter/foundation.dart';

enum AppLogLevel {
  debug,
  info,
  warning,
  error,
}

abstract final class AppLogger {
  static const Set<String> _sensitiveKeys = {
    'authorization',
    'apns_token',
    'cookie',
    'device_id',
    'fcm_token',
    'firebase_custom_token',
    'password',
    'refresh_token',
    'session',
    'token',
  };

  static void debug(String message, {Object? data}) {
    if (kDebugMode) {
      _write(AppLogLevel.debug, message, data: data);
    }
  }

  static void info(String message, {Object? data}) {
    if (kDebugMode) {
      _write(AppLogLevel.info, message, data: data);
    }
  }

  static void warning(String message, {Object? error, Object? data}) {
    _write(AppLogLevel.warning, message, error: error, data: data);
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Object? data,
  }) {
    _write(
      AppLogLevel.error,
      message,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  static void _write(
    AppLogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Object? data,
  }) {
    final prefix = switch (level) {
      AppLogLevel.debug => 'DEBUG',
      AppLogLevel.info => 'INFO',
      AppLogLevel.warning => 'WARN',
      AppLogLevel.error => 'ERROR',
    };
    debugPrint('[$prefix] $message');
    if (data != null) {
      debugPrint(_pretty(_redact(data)));
    }
    if (error != null) {
      debugPrint('[$prefix] error=${_redact(error)}');
    }
    if (stackTrace != null && kDebugMode) {
      debugPrint(stackTrace.toString());
    }
  }

  static Object? _redact(Object? value, [String? key]) {
    if (value == null) return null;
    if (key != null && _isSensitiveKey(key)) {
      return _maskValue(value);
    }
    if (value is Map) {
      return value.map(
        (k, v) => MapEntry(k, _redact(v, k.toString())),
      );
    }
    if (value is Iterable) {
      return value.map(_redact).toList(growable: false);
    }
    if (value is String && _looksSensitive(value)) {
      return _maskString(value);
    }
    return value;
  }

  static bool _isSensitiveKey(String key) {
    final normalized = key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    return _sensitiveKeys.any(normalized.contains);
  }

  static bool _looksSensitive(String value) {
    return RegExp(
      r'^[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}$',
    ).hasMatch(value);
  }

  static String _maskValue(Object value) {
    final text = value.toString();
    if (text.isEmpty) return '<empty>';
    return _maskString(text);
  }

  static String _maskString(String value) {
    if (value.length <= 8) return '***';
    return '${value.substring(0, 4)}...${value.substring(value.length - 4)}';
  }

  static String _pretty(Object? value) {
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return value.toString();
    }
  }
}
