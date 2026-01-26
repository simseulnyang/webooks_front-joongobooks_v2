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

/// 채팅 목록 화면 (채팅 탭)
class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    // TODO: 채팅방 목록 로드
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('채팅')),
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
              Icons.chat_bubble_outline,
              size: 100,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 24),

            Text('로그인이 필요합니다', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),

            Text(
              '채팅을 하려면 로그인 해주세요',
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
    return _buildBody();
  }

  Widget _buildBody() {
    // TODO: Provider 연결
    final isLoading = false;
    final hasError = false;
    final chatRooms = <dynamic>[];

    if (isLoading) {
      return const AppLoading(message: '채팅 목록을 불러오는 중...');
    }

    if (hasError) {
      return ErrorView(
        message: '채팅 목록을 불러오는데 실패했습니다.',
        onRetry: () {
          // TODO: 재시도
        },
      );
    }

    if (chatRooms.isEmpty) {
      return const EmptyView(
        message: '진행 중인 채팅이 없습니다.',
        icon: Icons.chat_bubble_outline,
      );
    }

    return ListView.separated(
      itemCount: chatRooms.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        // TODO: ChatTile 위젯으로 교체
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text('사용자 ${index + 1}', style: AppTextStyles.titleMedium),
          subtitle: Text(
            '마지막 메시지 내용...',
            style: AppTextStyles.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.chatRoom,
              arguments: {
                'roomId': index + 1,
                'otherUserName': '사용자 ${index + 1}',
              },
            );
          },
        );
      },
    );
  }
}
