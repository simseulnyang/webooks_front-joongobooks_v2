import 'package:json_annotation/json_annotation.dart';

import '../../../books/domain/models/book.dart';
import 'chat_user.dart';

part 'chat_room_list_item.g.dart';

@JsonSerializable()
class ChatRoomListItem {
  final int id;
  final BookListItem book;

  @JsonKey(name: 'other_user')
  final ChatUser? otherUser;

  @JsonKey(name: 'last_message')
  final LastMessage? lastMessage;

  @JsonKey(name: 'unread_count')
  final int unreadCount;

  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'updated_at')
  final String updatedAt;

  ChatRoomListItem({
    required this.id,
    required this.book,
    this.otherUser,
    this.lastMessage,
    this.unreadCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatRoomListItem.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomListItemFromJson(json);

  Map<String, dynamic> toJson() => _$ChatRoomListItemToJson(this);
}

@JsonSerializable()
class LastMessage {
  final String content;

  @JsonKey(name: 'created_at')
  final String createdAt;

  LastMessage({required this.content, required this.createdAt});

  factory LastMessage.fromJson(Map<String, dynamic> json) =>
      _$LastMessageFromJson(json);

  Map<String, dynamic> toJson() => _$LastMessageToJson(this);
}
