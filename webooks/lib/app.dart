import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes/app_router.dart';
import 'routes/app_routes.dart';
import 'shared/theme/app_theme.dart';

/// 앱의 뼈대를 정의하는 MaterialApp
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'WeBooks',
      debugShowCheckedModeBanner: false,

      // 테마 설정
      theme: AppTheme.lightTheme,

      // 초기 라우트
      initialRoute: AppRoutes.splash,

      // 라우트 생성
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
