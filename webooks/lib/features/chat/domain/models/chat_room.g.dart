// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatRoom _$ChatRoomFromJson(Map<String, dynamic> json) => ChatRoom(
  id: (json['id'] as num).toInt(),
  book: BookListItem.fromJson(json['book'] as Map<String, dynamic>),
  seller: ChatUser.fromJson(json['seller'] as Map<String, dynamic>),
  buyer: ChatUser.fromJson(json['buyer'] as Map<String, dynamic>),
  otherUser: json['other_user'] == null
      ? null
      : User.fromJson(json['other_user'] as Map<String, dynamic>),
  lastMessage: json['last_message'] == null
      ? null
      : LastMessage.fromJson(json['last_message'] as Map<String, dynamic>),
  unreadCount: (json['unread_count'] as num?)?.toInt(),
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$ChatRoomToJson(ChatRoom instance) => <String, dynamic>{
  'id': instance.id,
  'book': instance.book,
  'seller': instance.seller,
  'buyer': instance.buyer,
  'other_user': instance.otherUser,
  'last_message': instance.lastMessage,
  'unread_count': instance.unreadCount,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

LastMessage _$LastMessageFromJson(Map<String, dynamic> json) => LastMessage(
  content: json['content'] as String,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$LastMessageToJson(LastMessage instance) =>
    <String, dynamic>{
      'content': instance.content,
      'created_at': instance.createdAt,
    };
