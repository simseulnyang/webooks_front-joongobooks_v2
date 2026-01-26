import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../books/presentation/screens/book_list_screen.dart';
import '../../books/presentation/screens/favorite_book_list_screen.dart';
import '../../chat/presentation/screens/chat_list_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import 'widgets/bottom_nav_bar.dart';

/// 메인 Shell 화면 (하단 탭 포함)
class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key});

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  int _currentIndex = 0;

  // 각 탭에 해당하는 화면들
  final List<Widget> _screens = const [
    BookListScreen(), // 홈
    FavoriteBookListScreen(), // 좋아요
    ChatListScreen(), // 채팅
    ProfileScreen(), // 내정보
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
