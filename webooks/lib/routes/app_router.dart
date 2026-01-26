import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../features/splash/splash_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/shell/presentation/main_shell_screen.dart';
import '../features/books/presentation/screens/book_detail_screen.dart';
import '../features/books/presentation/screens/book_edit_screen.dart';
import '../features/chat/presentation/screens/chat_room_screen.dart';
import '../features/profile/presentation/profile_edit_screen.dart';

/// Navigator 1.0 라우터
/// onGenerateRoute에서 사용
class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Splash
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );

      // Auth
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      // Main Shell (하단 탭 포함)
      case AppRoutes.mainShell:
        return MaterialPageRoute(
          builder: (_) => const MainShellScreen(),
        );

      // Book Detail
      case AppRoutes.bookDetail:
        final bookId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => BookDetailScreen(bookId: bookId),
        );

      // Book Edit
      case AppRoutes.bookEdit:
        final bookId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => BookEditScreen(bookId: bookId),
        );

      // Chat Room
      case AppRoutes.chatRoom:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ChatRoomScreen(
            roomId: args['roomId'] as int,
            otherUserName: args['otherUserName'] as String,
          ),
        );

      // Profile Edit
      case AppRoutes.profileEdit:
        return MaterialPageRoute(
          builder: (_) => const ProfileEditScreen(),
        );

      // 404 - 잘못된 경로
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('404')),
            body: const Center(
              child: Text('페이지를 찾을 수 없습니다.'),
            ),
          ),
        );
    }
  }
}
