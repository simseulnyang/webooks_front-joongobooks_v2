import 'package:flutter/material.dart';
import 'package:webooks/features/chat/domain/models/chat_user.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../domain/models/chat_room_detail.dart';
import '../../domain/models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMine;

  final ChatRoomDetail room;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 상대방 프로필 이미지
          if (!isMine) ...[
            _buildProfileImage(message, room),
            const SizedBox(width: 8),
          ],

          // 시간 (내 메시지일 때 왼쪽)
          if (isMine) ...[_buildTimestamp(), const SizedBox(width: 8)],

          // 메시지 말풍선
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMine ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                message.content,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isMine ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),

          // 시간 (상대방 메시지일 때 오른쪽)
          if (!isMine) ...[const SizedBox(width: 8), _buildTimestamp()],
        ],
      ),
    );
  }

  Widget _buildProfileImage(Message message, ChatRoomDetail room) {
    final ChatUser user = (message.sender == room.buyer.id)
        ? room.buyer
        : room.seller;

    final imageUrl = user.profileImage;

    if (imageUrl.isNotEmpty) {
      return CircleAvatar(radius: 16, backgroundImage: NetworkImage(imageUrl));
    }
    return const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 20));
  }

  Widget _buildTimestamp() {
    // ISO 형식 파싱 및 포맷팅
    try {
      final dateTime = DateTime.parse(message.createdAt);
      final hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? '오후' : '오전';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

      return Text(
        '$period $displayHour:$minute',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
      );
    } catch (e) {
      // 파싱 실패 시 원본 그대로 표시
      return Text(
        message.createdAt,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
      );
    }
  }
}
