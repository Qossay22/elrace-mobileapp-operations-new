import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:el_race/core/services/device_details_headers.dart';
import 'package:el_race/core/utils/shared_pref.dart';
import 'package:el_race/ui/presentation/signin/data/model.dart';
import 'package:el_race/utils/api_query.dart';
import 'package:el_race/utils/string_utils.dart';
import 'package:el_race/utils/urll_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginUnreachableException implements Exception {
  const LoginUnreachableException();

  @override
  String toString() =>
      'Could not reach the server. Check your connection and try again.';
}

class UserRepo {
  static const String _loginDb = 'odoo.elrace.com';

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
      ...await DeviceDetailsHeaders.get(),
    };
    final body = {
      'jsonrpc': '2.0',
      'params': {
        'db': _loginDb,
        'login': email,
        'password': password,
        'device_id': deviceId,
        'fcm_token': fcmToken,
      },
    };

    _log('Sending login request to configured endpoint');
    final response =
        await apiQuery.postQuery(UrlUtil.login, headers, body, 'login', true);

    _log('Login response status: ${response?.statusCode}');
    _log('Login response type: ${response?.data.runtimeType}');

    if (response == null) throw const LoginUnreachableException();

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
