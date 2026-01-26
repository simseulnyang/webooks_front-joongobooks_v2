import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/application/auth_provider.dart';
import '../../../../routes/app_routes.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/app_button.dart';

/// 좋아요한 책 목록 화면 (좋아요 탭)
class FavoriteBookListScreen extends ConsumerStatefulWidget {
  const FavoriteBookListScreen({super.key});

  @override
  ConsumerState<FavoriteBookListScreen> createState() =>
      _FavoriteBookListScreenState();
}

class _FavoriteBookListScreenState
    extends ConsumerState<FavoriteBookListScreen> {
  @override
  void initState() {
    super.initState();
    // TODO: 좋아요 목록 로드
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('좋아요')),
      body: authState.isLoggedIn
          ? _buildLoggedInView()
          : _buildLoggedOutView(context),
    );
  }

  /// 로그인 전 화면
  Widget _buildLoggedOutView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite_border,
              size: 100,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 24),

            Text('로그인이 필요합니다', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),

            Text(
              '좋아요한 책을 보려면 로그인 해주세요',
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
    );
  }

  /// 로그인 후 화면
  Widget _buildLoggedInView() {
    return RefreshIndicator(
      onRefresh: () async {
        // TODO: 새로고침
      },
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    // TODO: Provider 연결
    final isLoading = false;
    final hasError = false;
    final favorites = <dynamic>[];

    if (isLoading) {
      return const AppLoading(message: '좋아요 목록을 불러오는 중...');
    }

    if (hasError) {
      return ErrorView(
        message: '좋아요 목록을 불러오는데 실패했습니다.',
        onRetry: () {
          // TODO: 재시도
        },
      );
    }

    if (favorites.isEmpty) {
      return const EmptyView(
        message: '좋아요한 책이 없습니다.',
        icon: Icons.favorite_border,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        // TODO: BookCard 위젯으로 교체
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: const Icon(Icons.favorite, color: Colors.red),
            title: Text('좋아요한 책 ${index + 1}'),
            subtitle: Text('₩ 15,000'),
          ),
        );
      },
    );
  }
}
