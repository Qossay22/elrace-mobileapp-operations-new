import 'package:el_race/core/logging/app_logger.dart';

/// Utility class for logging API requests and responses
class ApiLogger {
  static const bool _isEnabled = true;

  /// Log API Request
  static void logRequest({
    required String endpoint,
    required String method,
    Map<String, dynamic>? headers,
    dynamic body,
  }) {
    if (!_isEnabled) return;

    AppLogger.debug('API request', data: {
      'method': method,
      'endpoint': endpoint,
      if (headers != null && headers.isNotEmpty) 'headers': headers,
      if (body != null) 'body': body,
    });
  }

  /// Log API Response
  static void logResponse({
    required String endpoint,
    required int statusCode,
    dynamic responseBody,
    Duration? duration,
  }) {
    if (!_isEnabled) return;

    AppLogger.debug('API response', data: {
      'endpoint': endpoint,
      'status_code': statusCode,
      'status_group': _getStatusGroup(statusCode),
      if (duration != null) 'duration_ms': duration.inMilliseconds,
      if (responseBody != null) 'response_body': responseBody,
    });
  }

  /// Log API Error
  static void logError({
    required String endpoint,
    required dynamic error,
    StackTrace? stackTrace,
  }) {
    if (!_isEnabled) return;

    AppLogger.error(
      'API error',
      error: error,
      stackTrace: stackTrace,
      data: {'endpoint': endpoint},
    );
  }

  static String _getStatusGroup(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) {
      return 'success';
    } else if (statusCode >= 300 && statusCode < 400) {
      return 'redirect';
    } else if (statusCode >= 400 && statusCode < 500) {
      return 'client_error';
    } else if (statusCode >= 500) {
      return 'server_error';
    }
    return 'unknown';
  }

  /// Log simple message
  static void log(String message) {
    if (!_isEnabled) return;
    AppLogger.debug('API log', data: {'message': message});
  }
}
