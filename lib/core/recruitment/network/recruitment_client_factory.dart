import 'package:dio/dio.dart';
import 'package:el_race/core/recruitment/network/recruitment_api_client.dart';
import 'package:el_race/services/api_client.dart'
    show AuthErrorInterceptor, AuthInterceptor, RetryInterceptor;

RecruitmentApiClient createRecruitmentApiClient() {
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
  return RecruitmentApiClient(dio, useMock: false);
}
