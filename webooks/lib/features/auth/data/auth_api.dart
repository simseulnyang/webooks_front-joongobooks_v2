import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_provider.dart';
import '../../../core/utils/logger_provider.dart';
import '../domain/models/auth_response.dart';

part 'auth_api.g.dart';

class AuthApi {
  final Dio _dio;
  final Logger _logger;

  AuthApi({required Dio dio, required Logger logger})
    : _dio = dio,
      _logger = logger;

  Future<AuthResponse> kakaoLogin(String accessToken) async {
    try {
      _logger.d('🔑 카카오 로그인 요청 시작');

      final response = await _dio.post(
        'users/kakao/login/',
        data: {'provider': 'kakao', 'token': accessToken},
      );

      _logger.i('✅ 카카오 로그인 성공: ${response.data}');

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      _logger.e('❌ 카카오 로그인 실패: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }

  Future<AuthResponse> googleLogin(String idToken) async {
    try {
      _logger.d('🔑 구글 로그인 요청 시작');

      final response = await _dio.post(
        'users/google/login/',
        data: {'provider': 'google', 'token': idToken},
      );

      _logger.i('✅ 구글 로그인 성공: ${response.data}');

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      _logger.e('❌ 구글 로그인 실패: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }

  Future<void> logout(String refreshToken) async {
    try {
      _logger.d('🚪 로그아웃 요청 시작');

      await _dio.post('users/logout/', data: {'refresh_token': refreshToken});

      _logger.d('✅ 로그아웃 성공');
    } on DioException catch (e) {
      _logger.e('❌ 로그아웃 실패: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      _logger.d('🗑️ 회원 탈퇴 요청 시작');

      await _dio.delete('users/delete/', data: {'confirm': true});

      _logger.d('✅ 회원 탈퇴 성공');
    } on DioException catch (e) {
      _logger.e('❌ 회원 탈퇴 실패: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }
}

@riverpod
AuthApi authApi(Ref ref) {
  final dio = ref.watch(dioProvider);
  final logger = ref.watch(loggerProvider);
  return AuthApi(dio: dio, logger: logger);
}
