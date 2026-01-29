import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/auth/application/auth_provider.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../application/chat_room_provider.dart';
import '../../application/chat_room_list_provider.dart'; // ✅ 추가: 목록 뱃지 갱신용
import '../../application/chat_state.dart';
import '../../domain/models/chat_room_detail.dart';
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

  bool _didMarkReadOnce = false; // ✅ 중복 호출 방지

  @override
  void initState() {
    super.initState();

    // ✅ 여기서는 listen 금지. 명령(refresh)만 OK.
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
    // ✅ listen은 build 안에서만!
    ref.listen<ChatRoomState>(chatRoomProvider(widget.roomId), (
      prev,
      next,
    ) async {
      final myId = ref.read(authProvider).user?.id;

      // 1) 방/메시지가 준비되고, 내 id도 있을 때
      if (myId == null) return;
      if (next.room == null) return;
      if (next.messages.isEmpty) return;

      // 2) 아직 읽음처리 안 했고, 연결이 어느 정도 된 상태면(선택)
      if (_didMarkReadOnce) return;

      // ✅ 내가 받은(상대가 보낸) 안 읽은 메시지 id 모으기
      final unreadIds = next.messages
          .where((m) => !m.isRead && m.sender != myId)
          .where((m) => m.id > 0) // temp 메시지(-id) 제외
          .map((m) => m.id)
          .toList();

      if (unreadIds.isEmpty) {
        _didMarkReadOnce = true; // 읽을 게 없으면 한 번만 체크하고 끝
        return;
      }

      // ✅ provider 메서드 호출(읽음 처리)
      ref
          .read(chatRoomProvider(widget.roomId).notifier)
          .markMessagesAsRead(unreadIds);

      // ✅ 뱃지 갱신(목록 다시 로드)
      // 너무 자주 호출되면 부담이니, 읽음 처리 후 1회만
      ref.read(chatRoomListProvider.notifier).refresh();

      _didMarkReadOnce = true;
    });

    final ChatRoomState chatState = ref.watch(chatRoomProvider(widget.roomId));
    final authState = ref.watch(authProvider);

    final ChatRoomDetail? room = chatState.room;
    final String bookTitle = room?.book.title ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.otherUserName),
            if (bookTitle.isNotEmpty)
              Text(
                bookTitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textHint,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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
    if (chatState.isLoading && chatState.messages.isEmpty) {
      return const AppLoading(message: '메시지를 불러오는 중...');
    }

    if (chatState.error != null && chatState.messages.isEmpty) {
      return ErrorView(
        message: chatState.error!,
        onRetry: () {
          _didMarkReadOnce = false; // ✅ 재시도 시 초기화
          ref.read(chatRoomProvider(widget.roomId).notifier).refresh();
        },
      );
    }

    final ChatRoomDetail? room = chatState.room;
    if (room == null && chatState.messages.isEmpty) {
      return const AppLoading(message: '채팅방 정보를 불러오는 중...');
    }

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

        // ✅ 상대 메시지에 username 표시
        final senderName = message.senderUsername.isNotEmpty
            ? message.senderUsername
            : widget.otherUserName;

        return Column(
          crossAxisAlignment: isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isMine)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: Text(
                  senderName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ),
            MessageBubble(message: message, isMine: isMine, room: room),
            const SizedBox(height: 10),
          ],
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
