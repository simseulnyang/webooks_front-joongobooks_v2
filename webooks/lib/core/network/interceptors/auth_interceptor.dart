import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../storage/token_storage.dart';

/// 인증 토큰 자동 추가 인터셉터
/// 모든 API 요청에 자동으로 Authorization 헤더를 붙여줌
class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  final Logger _logger;
  final Dio _dio;

  AuthInterceptor({
    required TokenStorage tokenStorage,
    required Logger logger,
    required Dio dio,
  }) : _tokenStorage = tokenStorage,
       _logger = logger,
       _dio = dio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final isAuthEndpoint =
        options.path.contains('users/kakao/login/') ||
        options.path.contains('users/google/login/');

    if (isAuthEndpoint) {
      _logger.d('🔓 소셜 로그인 API - JWT 토큰 추가 안 함: ${options.uri.path}');
      return handler.next(options);
    }

    final accessToken = await _tokenStorage.getAccessToken();

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
      _logger.d('🔑 토큰 추가: ${options.uri.path}');
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 401 에러 (인증 실패) 시 처리 - 나중에 토큰 갱신 로직 추가 가능
    if (err.response?.statusCode == 401) {
      _logger.w('🚫 401 인증 실패 감지: ${err.requestOptions.uri.path}');
      final isLogoutRequest = err.requestOptions.path.contains('users/logout/');
      final isRefreshRequest = err.requestOptions.path.contains(
        'users/token/refresh/',
      );

      if (isLogoutRequest || isRefreshRequest) {
        _logger.d('로그아웃/갱신 요청 실패 - 에러 그대로 반환');
        return handler.next(err);
      }

      try {
        _logger.d('🔄 토큰 갱신 시도...');

        final newAccessToken = await _refreshToken();

        if (newAccessToken != null) {
          // 갱신 성공 → 원래 요청 재시도
          _logger.i('✅ 토큰 갱신 성공 - 원래 요청 재시도');

          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $newAccessToken';

          final response = await _dio.fetch(options);
          return handler.resolve(response);
        } else {
          // 갱신 실패 → 로그아웃 처리
          _logger.e('❌ 토큰 갱신 실패 - 자동 로그아웃');
          await _handleAutoLogout();
          return handler.next(err);
        }
      } catch (e) {
        _logger.e('❌ 토큰 갱신 중 예외 발생: $e');
        await _handleAutoLogout();
        return handler.next(err);
      }
    }

    return handler.next(err);
  }

  Future<String?> _refreshToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        _logger.w('⚠️ Refresh Token이 없음');
        return null;
      }

      _logger.d('📤 토큰 갱신 API 호출');

      final response = await _dio.post(
        'users/token/refresh/',
        data: {'refresh': refreshToken},
        options: Options(headers: {'Authorization': null}),
      );

      final newAccessToken = response.data['access'] as String;

      await _tokenStorage.saveAccessToken(newAccessToken);

      _logger.i('✅ 새 Access Token 저장 완료');

      return newAccessToken;
    } catch (e) {
      _logger.e('❌ 토큰 갱신 API 실패: $e');
      return null;
    }
  }

  Future<void> _handleAutoLogout() async {
    try {
      _logger.w('🚪 자동 로그아웃 처리 중...');

      await _tokenStorage.clearTokens();

      _logger.i('✅ 토큰 삭제 완료 - 사용자는 앱 재시작 시 로그인 화면으로 이동');
    } catch (e) {
      _logger.e('❌ 자동 로그아웃 실패: $e');
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d('✅ 응답 성공: ${response.requestOptions.uri.path}');
    return handler.next(response);
  }
}
