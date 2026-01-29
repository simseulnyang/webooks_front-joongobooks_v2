import 'package:json_annotation/json_annotation.dart';

import '../../../books/domain/models/book.dart';
import 'chat_user.dart';
import 'message.dart';

part 'chat_room_detail.g.dart';

@JsonSerializable()
class ChatRoomDetail {
  final int id;
  final BookListItem book;
  final ChatUser buyer;
  final ChatUser seller;
  final List<Message> messages;

  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'updated_at')
  final String updatedAt;

  const ChatRoomDetail({
    required this.id,
    required this.book,
    required this.buyer,
    required this.seller,
    this.messages = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatRoomDetail.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomDetailFromJson(json);

  Map<String, dynamic> toJson() => _$ChatRoomDetailToJson(this);
}
