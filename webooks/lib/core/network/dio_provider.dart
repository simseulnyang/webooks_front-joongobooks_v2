import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../storage/token_storage.dart';
import '../utils/logger_provider.dart';
import 'api_client.dart';
import 'interceptors/auth_interceptor.dart';

part 'dio_provider.g.dart';

/// Dio Provider
/// 앱 전역에서 Dio 인스턴스를 재사용
@riverpod
Dio dio(Ref ref) {
  final apiClient = ApiClient();
  final tokenStorage = ref.watch(tokenStorageProvider);
  final logger = ref.watch(loggerProvider);

  // AuthInterceptor 추가
  apiClient.addInterceptor(
    AuthInterceptor(
      tokenStorage: tokenStorage,
      logger: logger,
      dio: apiClient.dio,
    ),
  );

  // ✅ (추가) Dio 레벨 로그 인터셉터: request headers/response body 확인용
  apiClient.dio.interceptors.add(
    LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      logPrint: (obj) => logger.d(obj.toString()),
    ),
  );

  return apiClient.dio;
}
