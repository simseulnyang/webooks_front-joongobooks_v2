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

  /// REST API용
  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);

  /// ✅ WebSocket 전용 (sender가 int / String / Map 전부 올 수 있음)
  factory Message.fromWebSocket(Map<String, dynamic> json) {
    // room 처리
    final roomValue = json['room'];
    final int roomId = switch (roomValue) {
      int v => v,
      String v => int.tryParse(v) ?? 0,
      Map v =>
        (v['id'] is int) ? v['id'] as int : int.tryParse('${v['id']}') ?? 0,
      _ => 0,
    };

    // sender 처리
    final senderValue = json['sender'];
    final int senderId = switch (senderValue) {
      int v => v,
      String v => int.tryParse(v) ?? 0,
      Map v =>
        (v['id'] is int) ? v['id'] as int : int.tryParse('${v['id']}') ?? 0,
      _ => 0,
    };

    // ✅ username / email 추출 (여기가 이전 문제의 핵심)
    String senderUsername = '';
    String senderEmail = '';

    if (senderValue is Map) {
      senderUsername = (senderValue['username'] ?? '').toString();
      senderEmail = (senderValue['email'] ?? '').toString();
    }

    senderUsername = senderUsername.isNotEmpty
        ? senderUsername
        : (json['sender_username'] ?? json['senderUsername'] ?? '').toString();

    senderEmail = senderEmail.isNotEmpty
        ? senderEmail
        : (json['sender_email'] ?? json['senderEmail'] ?? '').toString();

    return Message(
      id: (json['id'] as num).toInt(),
      room: roomId,
      sender: senderId,
      senderUsername: senderUsername,
      senderEmail: senderEmail,
      content: (json['content'] ?? '').toString(),
      isRead: json['is_read'] is bool ? json['is_read'] as bool : false,
      createdAt: (json['created_at'] ?? '').toString(),
    );
  }

  /// ✅ Provider에서 읽음 처리 / optimistic update용
  Message copyWith({
    int? id,
    int? room,
    int? sender,
    String? senderUsername,
    String? senderEmail,
    String? content,
    bool? isRead,
    String? createdAt,
  }) {
    return Message(
      id: id ?? this.id,
      room: room ?? this.room,
      sender: sender ?? this.sender,
      senderUsername: senderUsername ?? this.senderUsername,
      senderEmail: senderEmail ?? this.senderEmail,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
