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
  apiClient.addInterceptor(AuthInterceptor(tokenStorage, logger));

  return apiClient.dio;
}
