import 'package:json_annotation/json_annotation.dart';

import '../../../auth/domain/models/user.dart';
import '../../../books/domain/models/book.dart';
import 'chat_user.dart';

part 'chat_room.g.dart';

@JsonSerializable()
class ChatRoom {
  final int id;
  final BookListItem book;
  final ChatUser seller;
  final ChatUser buyer;
  @JsonKey(name: 'other_user')
  final User? otherUser;
  @JsonKey(name: 'last_message')
  final LastMessage? lastMessage;
  @JsonKey(name: 'unread_count')
  final int? unreadCount;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  ChatRoom({
    required this.id,
    required this.book,
    required this.seller,
    required this.buyer,
    this.otherUser,
    this.lastMessage,
    this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomFromJson(json);

  Map<String, dynamic> toJson() => _$ChatRoomToJson(this);
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
