import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../routes/app_routes.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // 2초 대기 (스플래시 화면 표시)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, AppRoutes.mainShell);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.book,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 24),

            Text(
              'WeBooks',
              style: AppTextStyles.headlineLarge.copyWith(
                color: Colors.white,
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              '중고도서 거래 플랫폼',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),

            // 로딩 인디케이터
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
