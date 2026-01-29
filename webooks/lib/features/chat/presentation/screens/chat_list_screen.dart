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
import '../../application/chat_room_list_provider.dart';
import '../widgets/chat_room_tile.dart';

/// 채팅 목록 화면 (채팅 탭)
class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 무한 스크롤
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      ref.read(chatRoomListProvider.notifier).loadMoreRooms();
    }
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
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(chatRoomListProvider.notifier).refresh();
      },
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    final chatListState = ref.watch(chatRoomListProvider);

    // 초기 로딩
    if (chatListState.isLoading && chatListState.rooms.isEmpty) {
      return const AppLoading(message: '채팅 목록을 불러오는 중...');
    }

    // 에러
    if (chatListState.error != null && chatListState.rooms.isEmpty) {
      return ErrorView(
        message: chatListState.error!,
        onRetry: () {
          ref.read(chatRoomListProvider.notifier).refresh();
        },
      );
    }

    // 빈 목록
    if (chatListState.rooms.isEmpty) {
      return const EmptyView(
        message: '진행 중인 채팅이 없습니다.',
        icon: Icons.chat_bubble_outline,
      );
    }

    // 채팅방 목록
    return ListView.separated(
      controller: _scrollController,
      itemCount: chatListState.rooms.length + (chatListState.hasMore ? 1 : 0),
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        // 마지막 아이템 - 로딩 인디케이터
        if (index == chatListState.rooms.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: chatListState.isLoadingMore
                  ? const CircularProgressIndicator()
                  : const SizedBox.shrink(),
            ),
          );
        }

        // 채팅방 타일
        final room = chatListState.rooms[index];
        final otherUserName = room.otherUser?.username ?? '알 수 없음';
        return ChatRoomTile(
          room: room,
          onTap: () async {
            final result = await Navigator.pushNamed(
              context,
              AppRoutes.chatRoom,
              arguments: {'roomId': room.id, 'otherUserName': otherUserName},
            );

            if (result == true) {
              await ref.read(chatRoomListProvider.notifier).refresh();
            }
          },
        );
      },
    );
  }
}
