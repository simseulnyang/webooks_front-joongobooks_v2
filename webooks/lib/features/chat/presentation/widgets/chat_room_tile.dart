import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../domain/models/chat_room_list_item.dart';

/// 채팅방 타일 위젯
class ChatRoomTile extends StatelessWidget {
  final ChatRoomListItem room;
  final VoidCallback onTap;

  const ChatRoomTile({super.key, required this.room, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final unreadCount = room.unreadCount ?? 0;
    final otherUserName = room.otherUser?.username ?? '알 수 없음';

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            bottom: BorderSide(color: AppColors.divider, width: 1),
          ),
        ),
        child: Row(
          children: [
            // 프로필 이미지
            Stack(
              children: [
                _buildProfileImage(),
                // 읽지 않은 메시지가 있으면 초록 점 표시
                if (unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: unreadCount > 0
                            ? AppColors.success
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // 채팅 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상대방 이름 & 안 읽은 메시지 개수
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          otherUserName,
                          style: AppTextStyles.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : '$unreadCount',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),

                  // 책 제목
                  Text(
                    room.book.title,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // 마지막 메시지
                  if (room.lastMessage != null)
                    Text(
                      room.lastMessage!.content,
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    final otherUser = room.otherUser;
    final imageUrl = otherUser?.profileImage;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CircleAvatar(radius: 28, backgroundImage: NetworkImage(imageUrl));
    }

    return const CircleAvatar(radius: 28, child: Icon(Icons.person, size: 28));
  }
}
