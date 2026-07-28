import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:el_race/core/logging/app_logger.dart';
import 'package:el_race/core/utils/shared_pref.dart';
import 'package:el_race/ui/presentation/signin/data/model.dart';
import 'package:el_race/utils/api_query.dart';
import 'package:el_race/utils/string_utils.dart';
import 'package:el_race/utils/urll_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepo {
  ApiQuery apiQuery = ApiQuery();

  Future<Response> loginApiCall(
      String email, String password, String deviceId) async {
    AppLogger.info('Login API start', data: {
      'email': email,
      'device_id': deviceId,
    });

    // Get FCM token from SharedPreferences
    String? fcmToken = SharedPref().getPreferenceString(fcm_token);

    // If FCM token is null or empty, log a warning
    if (fcmToken.isEmpty) {
      AppLogger.warning('FCM token is empty during login');
    } else {
      AppLogger.debug('FCM token available', data: {'fcm_token': fcmToken});
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
          "jsonrpc": "2.0",
          "params": {
            "db": db,
            "login": email,
            "password": password,
            "device_id": deviceId,
            "fcm_token": fcmToken,
          }
        };

        AppLogger.debug('Sending login request', data: {
          'url': '${UrlUtil.baseUrl}$path',
          'body': body,
        });

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

    AppLogger.debug('Login response received', data: {
      'status_code': response?.statusCode,
      'data_type': response?.data.runtimeType.toString(),
    });

    if (response?.data != null) {
      AppLogger.debug('Login response payload', data: response!.data);

      // Parse and display important data
      try {
        final data = response.data;
        if (data['result'] != null) {
          final result = data['result'];
          AppLogger.info('Login successful', data: {
            'has_token': result['token'] != null,
          });

          if (result['data'] != null) {
            final userData = result['data'];
            AppLogger.debug('Login user summary', data: {
              'emp_id': userData['emp_id'],
              'emp_profile_id': userData['emp_profile_id'],
              'company_id': userData['company_id'],
              'qr_status': userData['qr_status'],
            });
          }
        } else if (data['error'] != null) {
          AppLogger.warning('Login failed', data: {'error': data['error']});
        }
      } catch (e) {
        AppLogger.warning('Could not parse login response', error: e);
      }
    } else {
      AppLogger.warning('No login response data received');
    }

    AppLogger.info('Login API end');

    return response!;
  }

  setLoginResponse(
    LoginResponseModel? loginResponse, {
    Map<String, dynamic>? rawJson,
  }) async {
    if (loginResponse != null) {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      final payload = rawJson ?? loginResponse.toJson();
      await sharedPreferences.setString('loginResponse', json.encode(payload));
    }
  }

  Future<LoginResponseModel?> getLoginResponse() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? userData = sharedPreferences.getString('loginResponse');

    if (userData == null) {
      return null;
    }

    final loginData = LoginResponseModel.fromJson(jsonDecode(userData));

    return loginData;
  }

  setISLoggedIn(bool isLoggedIn) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setBool(isLoggedIN, isLoggedIn);
  }

  Future<bool?> getIsLoggedIn() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(isLoggedIN) ?? false;
  }

  setDeviceInfo(String deviceInfo) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setString(deviceInfoString, deviceInfo);
  }

  Future<String?> getDeviceInfo() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(deviceInfoString) ?? '';
  }
}
