import 'package:dio/dio.dart';
import 'package:el_race/core/hr_management/network/hr_api_client.dart';
import 'package:el_race/services/api_client.dart'
    show AuthErrorInterceptor, AuthInterceptor, RetryInterceptor;

HrApiClient createHrApiClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://erp.elrace.com',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(),
    AuthErrorInterceptor(),
    RetryInterceptor(dio),
  ]);

  return HrApiClient(dio, useMock: false);
}
