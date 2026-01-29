import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/auth/application/auth_provider.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../application/chat_room_provider.dart';
import '../../application/chat_state.dart'; // ✅ ChatRoomState 타입 사용
import '../../domain/models/chat_room_detail.dart'; // ✅ room 타입 명시(선택)
import '../widgets/message_bubble.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  final int roomId;
  final String otherUserName;

  const ChatRoomScreen({
    super.key,
    required this.roomId,
    required this.otherUserName,
  });

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // ✅ 화면 진입 후 1프레임 뒤에 refresh 트리거 (provider lifecycle 안전)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(chatRoomProvider(widget.roomId).notifier);
      await notifier.refresh();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ChatRoomState chatState = ref.watch(chatRoomProvider(widget.roomId));
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.otherUserName),
            if (!chatState.isConnected)
              Text(
                '연결 중...',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textHint,
                ),
              ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: chatState.isConnected
                      ? AppColors.success
                      : AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList(chatState, authState.user?.id)),
          _buildMessageInput(chatState),
        ],
      ),
    );
  }

  Widget _buildMessageList(ChatRoomState chatState, int? currentUserId) {
    // 1) 초기 로딩
    if (chatState.isLoading && chatState.messages.isEmpty) {
      return const AppLoading(message: '메시지를 불러오는 중...');
    }

    // 2) 에러
    if (chatState.error != null && chatState.messages.isEmpty) {
      return ErrorView(
        message: chatState.error!,
        onRetry: () {
          ref.read(chatRoomProvider(widget.roomId).notifier).refresh();
        },
      );
    }

    // ✅ room(상세) 아직 안 들어온 경우 방어
    final ChatRoomDetail? room = chatState.room;
    if (room == null) {
      // 메시지가 이미 있는데 room만 null이면 이상하긴 하지만, 안전하게 처리
      return const AppLoading(message: '채팅방 정보를 불러오는 중...');
    }

    // 3) 빈 메시지
    if (chatState.messages.isEmpty) {
      return Center(
        child: Text(
          '메시지를 입력해보세요!',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: chatState.messages.length,
      itemBuilder: (context, index) {
        final message = chatState.messages[index];

        final isMine =
            (currentUserId != null) && (message.sender == currentUserId);

        return MessageBubble(
          message: message,
          isMine: isMine,
          room: room, // ✅ ChatRoomDetail 전달
        );
      },
    );
  }

  Widget _buildMessageInput(ChatRoomState chatState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: chatState.isConnected
                      ? '메시지를 입력하세요'
                      : '연결 중입니다… (잠시만요)',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textHint,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                enabled: true,
                onSubmitted: (_) => _sendMessage(chatState),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: chatState.isConnected
                    ? AppColors.primary
                    : AppColors.textHint,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () => _sendMessage(chatState),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(ChatRoomState chatState) {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    if (!chatState.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아직 연결 중입니다. 잠시 후 다시 시도해주세요.')),
      );
      return;
    }

    ref.read(chatRoomProvider(widget.roomId).notifier).sendMessage(text);
    _messageController.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
