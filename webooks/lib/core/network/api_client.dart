import 'package:dio/dio.dart';
import '../config/env_config.dart';

/// Dio 기본 설정 클래스
/// baseUrl, timeout 등 공통 설정
class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.apiBaseUrl, // .env에서 가져온 API URL
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 로그 인터셉터 추가 (개발 시 유용)
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  /// 인터셉터 추가 메서드 (AuthInterceptor 등을 나중에 추가)
  void addInterceptor(Interceptor interceptor) {
    dio.interceptors.add(interceptor);
  }
}
