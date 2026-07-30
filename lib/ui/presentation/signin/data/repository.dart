import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:el_race/core/utils/shared_pref.dart';
import 'package:el_race/ui/presentation/signin/data/model.dart';
import 'package:el_race/utils/api_query.dart';
import 'package:el_race/utils/string_utils.dart';
import 'package:el_race/utils/urll_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepo {
  ApiQuery apiQuery = ApiQuery();

  void _log(String message) {
    if (kDebugMode) debugPrint(message);
  }

  Future<Response> loginApiCall(
    String email,
    String password,
    String deviceId,
  ) async {
    _log('Login API start');

    final fcmToken = SharedPref().getPreferenceString(fcm_token);
    if (fcmToken.isEmpty) {
      _log('Login warning: FCM token is empty');
    } else {
      _log('Login request includes an FCM token');
    }

    final headers = {
      'Content-Type': 'application/json',
    };
    final loginPaths = <String>[
      UrlUtil.login,
      'login',
    ];
    final candidateDbs = <String>[
      'odoo.elrace.com',
      'erp.elrace.com',
      'elrace',
    ];

    Response? response;
    for (final path in loginPaths) {
      for (final db in candidateDbs) {
        final body = {
          'jsonrpc': '2.0',
          'params': {
            'db': db,
            'login': email,
            'password': password,
            'device_id': deviceId,
            'fcm_token': fcmToken,
          },
        };

        _log('Sending login request to configured endpoint');

        response = await apiQuery.postQuery(path, headers, body, 'login', true);
        final code = response?.statusCode ?? 0;
        final data = response?.data;
        final isSuccess = data is Map &&
            data['result'] is Map &&
            (data['result']['success'] == true ||
                data['result']['token'] != null);
        if (code == 200 && isSuccess) {
          break;
        }
      }
      final data = response?.data;
      final ok = response?.statusCode == 200 &&
          data is Map &&
          data['result'] is Map &&
          (data['result']['success'] == true ||
              data['result']['token'] != null);
      if (ok) break;
    }

    _log('Login response status: ${response?.statusCode}');
    _log('Login response type: ${response?.data.runtimeType}');

    if (response == null) {
      throw Exception('Login request failed without a response');
    }

    return response;
  }

  setLoginResponse(
    LoginResponseModel? loginResponse, {
    Map<String, dynamic>? rawJson,
  }) async {
    if (loginResponse != null) {
      final sharedPreferences = await SharedPreferences.getInstance();
      final payload = rawJson ?? loginResponse.toJson();
      await sharedPreferences.setString('loginResponse', json.encode(payload));
    }
  }

  Future<LoginResponseModel?> getLoginResponse() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final userData = sharedPreferences.getString('loginResponse');

    if (userData == null) {
      return null;
    }

    return LoginResponseModel.fromJson(jsonDecode(userData));
  }

  setISLoggedIn(bool isLoggedIn) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setBool(isLoggedIN, isLoggedIn);
  }

  Future<bool?> getIsLoggedIn() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(isLoggedIN) ?? false;
  }

  setDeviceInfo(String deviceInfo) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setString(deviceInfoString, deviceInfo);
  }

  Future<String?> getDeviceInfo() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(deviceInfoString) ?? '';
  }
}
