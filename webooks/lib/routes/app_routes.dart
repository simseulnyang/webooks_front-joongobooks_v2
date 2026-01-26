/// 앱에서 사용하는 라우트 경로 상수 모음
class AppRoutes {
  // Splash
  static const String splash = '/';

  // Auth
  static const String login = '/login';

  // Main Shell (하단 탭)
  static const String mainShell = '/main';

  // Books
  static const String bookList = '/main/books'; // 홈 탭
  static const String bookDetail = '/book/detail';
  static const String bookEdit = '/book/edit';
  static const String bookCreate = '/book/create';

  // Favorites
  static const String favoriteBooks = '/main/favorites'; // 좋아요 탭

  // Chat
  static const String chatList = '/main/chat'; // 채팅 탭
  static const String chatRoom = '/chat/room';

  // Profile
  static const String profile = '/main/profile'; // 내정보 탭
  static const String profileEdit = '/profile/edit';
}
