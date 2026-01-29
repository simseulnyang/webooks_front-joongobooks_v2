// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
  id: (json['id'] as num).toInt(),
  room: (json['room'] as num).toInt(),
  sender: (json['sender'] as num).toInt(),
  senderUsername: json['sender_username'] as String,
  senderEmail: json['sender_email'] as String,
  content: json['content'] as String,
  isRead: json['is_read'] as bool,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  'id': instance.id,
  'room': instance.room,
  'sender': instance.sender,
  'sender_username': instance.senderUsername,
  'sender_email': instance.senderEmail,
  'content': instance.content,
  'is_read': instance.isRead,
  'created_at': instance.createdAt,
};
