import 'package:dio/dio.dart';
import 'package:el_race/core/payslip/network/payslip_api_client.dart';
import 'package:el_race/services/api_client.dart'
    show AuthErrorInterceptor, AuthInterceptor, RetryInterceptor;

PayslipApiClient createPayslipApiClient() {
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
  return PayslipApiClient(dio);
}
