import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
class Message {
  final int id;
  @JsonKey(name: 'room')
  final int room;
  final int sender;
  @JsonKey(name: 'sender_username')
  final String senderUsername;
  @JsonKey(name: 'sender_email')
  final String senderEmail;
  final String content;
  @JsonKey(name: 'is_read')
  final bool isRead;
  @JsonKey(name: 'created_at')
  final String createdAt;

  Message({
    required this.id,
    required this.room,
    required this.sender,
    required this.senderUsername,
    required this.senderEmail,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);

  factory Message.fromWebSocket(Map<String, dynamic> json) {
    final roomValue = json['room'];
    final int roomId = switch (roomValue) {
      int v => v,
      String v => int.tryParse(v) ?? 0,
      Map v =>
        (v['id'] is int) ? v['id'] as int : int.tryParse('${v['id']}') ?? 0,
      _ => 0,
    };
    final senderValue = json['sender'];
    final int senderId = switch (senderValue) {
      int v => v,
      String v => int.tryParse(v) ?? 0,
      Map v =>
        (v['id'] is int) ? v['id'] as int : int.tryParse('${v['id']}') ?? 0,
      _ => 0,
    };

    final String username =
        (json['sender_username'] ?? json['senderUsername'] ?? '').toString();
    final String email = (json['sender_email'] ?? json['senderEmail'] ?? '')
        .toString();

    return Message(
      id: (json['id'] as num).toInt(),
      room: roomId,
      sender: senderId,
      senderUsername: username,
      senderEmail: email,
      content: (json['content'] ?? '').toString(),
      isRead: (json['is_read'] is bool) ? json['is_read'] as bool : false,
      createdAt: (json['created_at'] ?? '').toString(),
    );
  }
}
