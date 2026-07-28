import 'package:dio/dio.dart';
import 'package:el_race/core/performance/network/performance_api_client.dart';
import 'package:el_race/services/api_client.dart'
    show AuthErrorInterceptor, AuthInterceptor, RetryInterceptor;

PerformanceApiClient createPerformanceApiClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://erp.elrace.com',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: const {
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
  return PerformanceApiClient(dio);
}
