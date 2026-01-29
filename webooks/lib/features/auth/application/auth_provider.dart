import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/error/api_error.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/utils/logger_provider.dart';
import '../data/auth_api.dart';
import 'auth_state.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  AuthState build() {
    _checkLoginStatus();
    return const AuthState();
  }

  Future<void> _checkLoginStatus() async {
    final tokenStorage = ref.read(tokenStorageProvider);
    final hasToken = await tokenStorage.hasToken();

    if (hasToken) {
      final logger = ref.read(loggerProvider);
      logger.d('🔑 저장된 토큰 발견 - 로그인 상태 유지');
    }
  }

  Future<void> loginWithKakao(String accessToken) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final logger = ref.read(loggerProvider);
      logger.d('🔍 [Auth Provider] 카카오 로그인 시작');
      logger.d(
        '🔍 [Auth Provider] Access Token: ${accessToken.substring(0, 20)}...',
      );

      final authApi = ref.read(authApiProvider);

      logger.d('🔍 [Auth Provider] API 호출 중...');
      final authResponse = await authApi.kakaoLogin(accessToken);

      logger.d('✅ [Auth Provider] API 응답 받음');
      logger.d('✅ [Auth Provider] User: ${authResponse.user.email}');

      // 토큰 저장
      logger.d('🔍 [Auth Provider] 토큰 저장 중...');
      final tokenStorage = ref.read(tokenStorageProvider);
      await tokenStorage.saveAccessToken(authResponse.accessToken);
      await tokenStorage.saveRefreshToken(authResponse.refreshToken);

      logger.d('✅ [Auth Provider] 토큰 저장 완료');

      // 상태 업데이트
      state = state.copyWith(user: authResponse.user, isLoading: false);

      logger.d('✅ [Auth Provider] 카카오 로그인 성공: ${authResponse.user.email}');

      if (authResponse.isCreated) {
        logger.d('🎉 [Auth Provider] 신규 회원가입');
      } else {
        logger.d('👋 [Auth Provider] 기존 회원 로그인');
      }
    } on DioException catch (e) {
      final logger = ref.read(loggerProvider);
      logger.e('❌ [Auth Provider] DioException 발생');
      logger.e('상태 코드: ${e.response?.statusCode}');
      logger.e('응답 데이터: ${e.response?.data}');

      final apiError = ApiError.fromDioException(e);

      // 409 Conflict: 다른 provider로 이미 가입된 경우
      if (apiError.statusCode == 409) {
        final errorMessage =
            apiError.errors?['email'] as String? ?? apiError.message;
        state = state.copyWith(isLoading: false, error: errorMessage);
        return;
      }

      // 400 Bad Request: 이메일 동의 필요 등
      if (apiError.statusCode == 400) {
        final emailError = apiError.errors?['email'] as String?;
        if (emailError != null) {
          state = state.copyWith(
            isLoading: false,
            error: '카카오 로그인 시 이메일 제공 동의가 필요합니다.',
          );
          return;
        }
      }

      state = state.copyWith(isLoading: false, error: apiError.message);
    } catch (e, stackTrace) {
      final logger = ref.read(loggerProvider);
      logger.e('❌ [Auth Provider] 예상치 못한 오류', error: e, stackTrace: stackTrace);

      state = state.copyWith(
        isLoading: false,
        error: '로그인 중 오류가 발생했습니다. 다시 시도해주세요.',
      );
    }
    // try {
    //   final authApi = ref.read(authApiProvider);
    //   final authResponse = await authApi.kakaoLogin(accessToken);

    //   final tokenStorage = ref.read(tokenStorageProvider);
    //   await tokenStorage.saveAccessToken(authResponse.accessToken);
    //   await tokenStorage.saveRefreshToken(authResponse.refreshToken);

    //   state = state.copyWith(user: authResponse.user, isLoading: false);

    //   final logger = ref.read(loggerProvider);
    //   logger.d('✅ 카카오 로그인 성공: ${authResponse.user.email}');

    //   if (authResponse.isCreated) {
    //     logger.d('🎉 신규 사용자 가입 완료');
    //   } else {
    //     logger.d('🔄 기존 회원 로그인');
    //   }
    // } on DioException catch (e) {
    //   final logger = ref.read(loggerProvider);
    //   logger.e('❌ 카카오 로그인 실패', error: e);

    //   final apiError = ApiError.fromDioException(e);

    //   if (apiError.statusCode == 409) {
    //     final errorMessage =
    //         apiError.errors?['email'] as String? ?? apiError.message;

    //     state = state.copyWith(isLoading: false, error: errorMessage);
    //     return;
    //   }

    //   if (apiError.statusCode == 400) {
    //     final emailError = apiError.errors?['email'] as String?;
    //     if (emailError != null) {
    //       state = state.copyWith(
    //         isLoading: false,
    //         error: '카카오 로그인 시 이메일 제공 동의가 필요합니다.',
    //       );
    //       return;
    //     }
    //   }
    //   state = state.copyWith(isLoading: false, error: apiError.message);
    // } catch (e, stackTrace) {
    //   final logger = ref.read(loggerProvider);
    //   logger.e('❌ 카카오 로그인 중 예상치 못한 오류', error: e, stackTrace: stackTrace);

    //   state = state.copyWith(
    //     isLoading: false,
    //     error: '로그인 중 오류가 발생했습니다. 다시 시도해주세요.',
    //   );
    // }
  }

  Future<void> loginWithGoogle(String idToken) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authApi = ref.read(authApiProvider);
      final authResponse = await authApi.googleLogin(idToken);

      final tokenStorage = ref.read(tokenStorageProvider);
      await tokenStorage.saveAccessToken(authResponse.accessToken);
      await tokenStorage.saveRefreshToken(authResponse.refreshToken);

      state = state.copyWith(user: authResponse.user, isLoading: false);

      final logger = ref.read(loggerProvider);
      logger.d('✅ 구글 로그인 성공: ${authResponse.user.email}');

      if (authResponse.isCreated) {
        logger.d('🎉 신규 사용자 가입 완료');
      } else {
        logger.d('🔄 기존 회원 로그인');
      }
    } on DioException catch (e) {
      final logger = ref.read(loggerProvider);
      logger.e('❌ 구글 로그인 실패', error: e);

      final apiError = ApiError.fromDioException(e);

      if (apiError.statusCode == 409) {
        final errorMessage =
            apiError.errors?['email'] as String? ?? apiError.message;
        state = state.copyWith(isLoading: false, error: errorMessage);
        return;
      }

      if (apiError.statusCode == 400) {
        final emailError = apiError.errors?['email'] as String?;
        if (emailError != null) {
          state = state.copyWith(
            isLoading: false,
            error: '구글 로그인 시 이메일 인증이 필요합니다.',
          );
          return;
        }
      }

      state = state.copyWith(isLoading: false, error: apiError.message);
    } catch (e, stackTrace) {
      final logger = ref.read(loggerProvider);
      logger.e('❌ 구글 로그인 중 예상치 못한 오류', error: e, stackTrace: stackTrace);

      state = state.copyWith(
        isLoading: false,
        error: '로그인 중 오류가 발생했습니다. 다시 시도해주세요.',
      );
    }
  }

  Future<void> logout() async {
    try {
      final tokenStorage = ref.read(tokenStorageProvider);
      final refreshToken = await tokenStorage.getRefreshToken();

      if (refreshToken != null) {
        final authApi = ref.read(authApiProvider);
        await authApi.logout(refreshToken);
      }

      await tokenStorage.clearTokens();

      state = const AuthState();

      final logger = ref.read(loggerProvider);
      logger.d('✅ 로그아웃 성공');
    } catch (e, stackTrace) {
      final logger = ref.read(loggerProvider);
      logger.e('❌ 로그아웃 실패', error: e, stackTrace: stackTrace);

      // 로그아웃 실패해도 토큰은 삭제
      final tokenStorage = ref.read(tokenStorageProvider);
      await tokenStorage.clearTokens();
      state = const AuthState();
    }
  }

  Future<void> deleteAccount() async {
    try {
      final authApi = ref.read(authApiProvider);
      await authApi.deleteAccount();

      final tokenStorage = ref.read(tokenStorageProvider);
      await tokenStorage.clearTokens();

      state = const AuthState();

      final logger = ref.read(loggerProvider);
      logger.d('✅ 회원 탈퇴 성공');
    } catch (e, stackTrace) {
      final logger = ref.read(loggerProvider);
      logger.e('❌ 회원 탈퇴 실패', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> updateProfile({String? username, String? profileImage}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final userApi = ref.read(authApiProvider);
      final updatedUser = await userApi.updateProfile(
        username: username,
        profileImage: profileImage,
      );

      state = state.copyWith(user: updatedUser, isLoading: false);

      final logger = ref.read(loggerProvider);
      logger.d('✅ 프로필 수정 성공: ${updatedUser.username}');
    } on DioException catch (e) {
      final logger = ref.read(loggerProvider);
      logger.e('❌ 프로필 수정 실패', error: e);

      final apiError = ApiError.fromDioException(e);

      // 400 에러 - 유효성 검사 실패
      if (apiError.statusCode == 400) {
        final usernameError = apiError.errors?['username'] as String?;
        if (usernameError != null) {
          state = state.copyWith(isLoading: false, error: usernameError);
          return;
        }
      }

      state = state.copyWith(isLoading: false, error: apiError.message);
    } catch (e, stackTrace) {
      final logger = ref.read(loggerProvider);
      logger.e('❌ 프로필 수정 중 예상치 못한 오류', error: e, stackTrace: stackTrace);

      state = state.copyWith(
        isLoading: false,
        error: '프로필 수정 중 오류가 발생했습니다. 다시 시도해주세요.',
      );
    }
  }
}
