import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_loading.dart';

/// 1:1 채팅방 화면
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
    // TODO: WebSocket 연결 및 과거 메시지 로드
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    // TODO: WebSocket 연결 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: 채팅방 설정
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 메시지 리스트
          Expanded(
            child: _buildMessageList(),
          ),

          // 메시지 입력창
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    // TODO: Provider 연결
    final isLoading = false;
    final messages = <Map<String, dynamic>>[];

    if (isLoading) {
      return const AppLoading(message: '메시지를 불러오는 중...');
    }

    if (messages.isEmpty) {
      return Center(
        child: Text(
          '메시지를 입력해보세요!',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textHint,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMine = message['isMine'] ?? false;

        return _buildMessageBubble(
          message: message['text'] ?? '',
          isMine: isMine,
          timestamp: message['timestamp'] ?? '',
        );
      },
    );
  }

  Widget _buildMessageBubble({
    required String message,
    required bool isMine,
    required String timestamp,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            const CircleAvatar(
              radius: 16,
              child: Icon(Icons.person, size: 20),
            ),
            const SizedBox(width: 8),
          ],
          if (isMine && timestamp.isNotEmpty) ...[
            Text(
              timestamp,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isMine ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isMine ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),
          if (!isMine && timestamp.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              timestamp,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 입력 필드
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: '메시지를 입력하세요',
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
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),

            // 전송 버튼
            Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // TODO: 메시지 전송 로직
    _messageController.clear();

    // 스크롤을 맨 아래로
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
