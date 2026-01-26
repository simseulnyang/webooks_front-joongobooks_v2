import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'secure_storage.dart';

part 'token_storage.g.dart';

/// JWT 토큰 관리 클래스
class TokenStorage {
  final SecureStorage _secureStorage;

  // 토큰 저장 키
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  TokenStorage(this._secureStorage);

  /// Access Token 저장
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(_accessTokenKey, token);
  }

  /// Refresh Token 저장
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(_refreshTokenKey, token);
  }

  /// Access Token 가져오기
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(_accessTokenKey);
  }

  /// Refresh Token 가져오기
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(_refreshTokenKey);
  }

  /// 토큰 전체 삭제 (로그아웃)
  Future<void> clearTokens() async {
    await _secureStorage.delete(_accessTokenKey);
    await _secureStorage.delete(_refreshTokenKey);
  }

  /// 토큰이 존재하는지 확인 (로그인 상태 체크)
  Future<bool> hasToken() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }
}

/// TokenStorage Provider
@riverpod
TokenStorage tokenStorage(Ref ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return TokenStorage(secureStorage);
}
