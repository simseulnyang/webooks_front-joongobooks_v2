// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatRoomDetail _$ChatRoomDetailFromJson(Map<String, dynamic> json) =>
    ChatRoomDetail(
      id: (json['id'] as num).toInt(),
      book: BookListItem.fromJson(json['book'] as Map<String, dynamic>),
      buyer: ChatUser.fromJson(json['buyer'] as Map<String, dynamic>),
      seller: ChatUser.fromJson(json['seller'] as Map<String, dynamic>),
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$ChatRoomDetailToJson(ChatRoomDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'book': instance.book,
      'buyer': instance.buyer,
      'seller': instance.seller,
      'messages': instance.messages,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
