import 'package:dio/dio.dart';
import '../../storage/token_storage.dart';
import '../../utils/logger_provider.dart';

/// 인증 토큰 자동 추가 인터셉터
/// 모든 API 요청에 자동으로 Authorization 헤더를 붙여줌
class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  final  logger;

  AuthInterceptor(this._tokenStorage, this.logger);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Access Token 가져오기
    final accessToken = await _tokenStorage.getAccessToken();

    // 토큰이 있으면 헤더에 추가
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
      logger.d('🔑 토큰 추가: ${options.uri.path}');
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 401 에러 (인증 실패) 시 처리 - 나중에 토큰 갱신 로직 추가 가능
    if (err.response?.statusCode == 401) {
      logger.e('🚫 인증 실패: 토큰이 만료되었거나 유효하지 않습니다.');
      // TODO: 토큰 갱신 로직 또는 로그아웃 처리
    }

    return handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.d('✅ 응답 성공: ${response.requestOptions.uri.path}');
    return handler.next(response);
  }
}
