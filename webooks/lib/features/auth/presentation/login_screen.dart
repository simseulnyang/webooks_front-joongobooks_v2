import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:webooks/features/auth/application/auth_state.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../application/auth_provider.dart';
import 'widgets/social_login_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isKakaoLoading = false;
  bool _isGoogleLoading = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isLoading) {
      } else {
        setState(() {
          _isKakaoLoading = false;
          _isGoogleLoading = false;
        });
      }

      if (next.user != null && !next.isLoading) {
        Navigator.pushReplacementNamed(context, AppRoutes.mainShell);
      }

      if (next.error != null) {
        _showErrorSnackBar(next.error!);
      }
    });

    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.book, size: 100, color: AppColors.primary),
              const SizedBox(height: 24),

              Text(
                'WeBooks',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                '중고도서 거래 플랫폼',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 80),

              // 카카오 로그인 버튼
              SocialLoginButton(
                text: '카카오로 시작하기',
                onPressed: authState.isLoading ? null : _handleKakaoLogin,
                isLoading: _isKakaoLoading,
                backgroundColor: const Color(0xFFFEE500),
                textColor: const Color(0xFF000000),
                icon: Icons.chat_bubble,
              ),

              const SizedBox(height: 16),

              // 구글 로그인 버튼
              SocialLoginButton(
                text: '구글로 시작하기',
                onPressed: authState.isLoading ? null : _handleGoogleLogin,
                isLoading: _isGoogleLoading,
                backgroundColor: Colors.white,
                textColor: AppColors.textPrimary,
                icon: Icons.g_mobiledata,
              ),

              const SizedBox(height: 40),

              Text(
                '로그인하면 서비스 이용약관 및\n개인정보 처리방침에 동의하게 됩니다.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textHint,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleKakaoLogin() async {
    setState(() => _isKakaoLoading = true);

    try {
      bool isInstalled = await kakao.isKakaoTalkInstalled();

      kakao.OAuthToken token;
      if (isInstalled) {
        token = await kakao.UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
      }

      await ref.read(authProvider.notifier).loginWithKakao(token.accessToken);
    } on kakao.KakaoException catch (e) {
      if (mounted) {
        // 사용자가 로그인 취소
        if (e.toString().contains('CANCELED')) {
          setState(() => _isKakaoLoading = false);
          return;
        }

        _showErrorSnackBar('카카오 로그인 실패: ${e.message}');
        setState(() => _isKakaoLoading = false);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('카카오 로그인 중 오류가 발생했습니다.');
        setState(() => _isKakaoLoading = false);
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isGoogleLoading = true);

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
      );

      // 기존 로그인 세션 정리
      await googleSignIn.signOut();

      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) {
        if (mounted) {
          setState(() => _isGoogleLoading = false);
        }
        return;
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null) {
        throw Exception('구글 ID 토큰을 가져올 수 없습니다.');
      }

      await ref.read(authProvider.notifier).loginWithGoogle(idToken);
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('구글 로그인 중 오류가 발생했습니다.');
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: '확인',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
