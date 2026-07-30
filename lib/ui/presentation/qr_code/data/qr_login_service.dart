import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:el_race/core/utils/shared_pref.dart';
import 'package:flutter/foundation.dart';

class QrLoginService {
  final Dio _dio = Dio();
  static const String baseUrl = 'https://rcc.sawatech.ae/api/auth';

  void _log(String message) {
    if (kDebugMode) debugPrint(message);
  }

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  int? _resolveUserId(dynamic data) {
    if (data == null) return null;
    final map = data as dynamic;
    return _asInt(map.odoo_user_id) ?? _asInt(map.uid) ?? _asInt(map.user_id);
  }

  String _extractCodeFromQr(String qrRaw) {
    final raw = qrRaw.trim();

    try {
      final qrJson = jsonDecode(raw);
      if (qrJson is Map) {
        for (final key in ['code', 'qr_code', 'token', 'login_code']) {
          final value = qrJson[key];
          final parsed = value?.toString().trim();
          if (parsed != null && parsed.isNotEmpty) {
            return parsed;
          }
        }
      }
    } catch (_) {
      // Not JSON, continue with URL/text parsing.
    }

    final uri = Uri.tryParse(raw);
    if (uri != null && (uri.hasScheme || uri.host.isNotEmpty)) {
      for (final key in ['code', 'qr', 'token', 'login_code']) {
        final q = uri.queryParameters[key]?.trim();
        if (q != null && q.isNotEmpty) {
          return q;
        }
      }

      if (uri.pathSegments.isNotEmpty) {
        final last = uri.pathSegments.last.trim();
        if (last.isNotEmpty &&
            !last.contains('.php') &&
            !last.contains('.html')) {
          return last;
        }
      }
    }

    return raw;
  }

  /// Login to website using QR code.
  Future<Map<String, dynamic>> loginWithQrCode(String qrCode) async {
    try {
      _log('QR login request started');

      final loginData = SharedPref.getLoginData();
      final odooId = _resolveUserId(loginData.result?.data);

      if (odooId == null) {
        _log('QR login aborted: user session is missing');
        return {
          'success': false,
          'message': 'User session not found. Please login again.',
        };
      }

      final actualCode = _extractCodeFromQr(qrCode);
      final encodedCode = Uri.encodeComponent(actualCode);
      final url = '$baseUrl/login-with-code/$encodedCode';

      final response = await _dio.post(
        url,
        data: {'odoo_id': odooId},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          validateStatus: (status) => true,
        ),
      );

      _log('QR login response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Login successful',
          'data': response.data,
        };
      }

      return {
        'success': false,
        'message': response.data?['message'] ?? 'Login failed',
        'data': response.data,
      };
    } catch (e) {
      _log('QR login request failed: $e');
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }
}
