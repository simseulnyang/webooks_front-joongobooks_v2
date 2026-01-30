import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/application/auth_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/app_button.dart';

import '../../books/presentation/screens/favorite_book_list_screen.dart';

/// 프로필 화면 (내정보 탭)
/// 로그인 여부에 따라 다른 화면 표시
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // 로딩 중
    if (authState.isLoading) {
      return const Scaffold(body: AppLoading(message: '프로필을 불러오는 중...'));
    }

    // 로그인 여부에 따라 다른 화면 표시
    if (authState.isLoggedIn) {
      return _ProfileLoggedInView(user: authState.user!);
    } else {
      return const _ProfileLoggedOutView();
    }
  }
}

/// 로그인 전 화면
class _ProfileLoggedOutView extends StatelessWidget {
  const _ProfileLoggedOutView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내정보')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_outline,
                size: 100,
                color: AppColors.textHint,
              ),
              const SizedBox(height: 24),

              Text('로그인이 필요합니다', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 8),

              Text(
                '내정보를 보려면 로그인 해주세요',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              AppButton(
                text: '로그인하기',
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.login);
                },
                icon: Icons.login,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 로그인 후 화면
class _ProfileLoggedInView extends ConsumerWidget {
  final user;

  const _ProfileLoggedInView({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내정보'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: 설정 화면
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // 프로필 헤더
          _buildProfileHeader(context, user),

          const SizedBox(height: 16),
          const Divider(height: 1),

          // 내 책 목록
          _buildMenuTile(
            icon: Icons.book_outlined,
            title: '내가 등록한 책',
            onTap: () {
              // TODO: 내가 등록한 책 목록
            },
          ),

          // 좋아요한 책
          _buildMenuTile(
            icon: Icons.favorite_outline,
            title: '좋아요한 책',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FavoriteBookListScreen(),
                ),
              );
            },
          ),

          const Divider(height: 1),

          // 프로필 수정
          _buildMenuTile(
            icon: Icons.edit_outlined,
            title: '프로필 수정',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.profileEdit);
            },
          ),

          // 알림 설정
          _buildMenuTile(
            icon: Icons.notifications_outlined,
            title: '알림 설정',
            onTap: () {
              // TODO: 알림 설정
            },
          ),

          const Divider(height: 1),

          // 공지사항
          _buildMenuTile(
            icon: Icons.campaign_outlined,
            title: '공지사항',
            onTap: () {
              // TODO: 공지사항
            },
          ),

          // 문의하기
          _buildMenuTile(
            icon: Icons.help_outline,
            title: '문의하기',
            onTap: () {
              // TODO: 문의하기
            },
          ),

          const Divider(height: 1),

          // 로그아웃
          _buildMenuTile(
            icon: Icons.logout,
            title: '로그아웃',
            textColor: AppColors.error,
            onTap: () {
              _showLogoutDialog(context, ref);
            },
          ),

          // 회원탈퇴
          _buildMenuTile(
            icon: Icons.person_remove_outlined,
            title: '회원탈퇴',
            textColor: AppColors.error,
            onTap: () {
              _showDeleteAccountDialog(context, ref);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, user) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // 프로필 이미지
          user.profileImage.isNotEmpty
              ? CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(user.profileImage),
                )
              : const CircleAvatar(
                  radius: 40,
                  child: Icon(Icons.person, size: 40),
                ),
          const SizedBox(width: 16),

          // 사용자 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.username, style: AppTextStyles.titleLarge),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // 프로필 수정 버튼
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profileEdit);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(color: textColor),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // 로그아웃 실행
              await ref.read(authProvider.notifier).logout();

              // 스낵바 표시
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('로그아웃되었습니다.'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              }
            },
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회원탈퇴'),
        content: const Text('정말 탈퇴하시겠습니까?\n모든 데이터가 삭제되며 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                // 회원탈퇴 실행
                await ref.read(authProvider.notifier).deleteAccount();

                // 스낵바 표시
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('회원탈퇴가 완료되었습니다.'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                }
              } catch (e) {
                // 에러 처리
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('회원탈퇴 중 오류가 발생했습니다: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('탈퇴하기'),
          ),
        ],
      ),
    );
  }
}
