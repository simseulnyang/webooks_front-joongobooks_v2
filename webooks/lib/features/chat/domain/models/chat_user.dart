import 'package:json_annotation/json_annotation.dart';

part 'chat_user.g.dart';

@JsonSerializable()
class ChatUser {
  final int id;
  final String username;
  final String? email;

  @JsonKey(name: 'profile_image')
  final String profileImage;

  ChatUser({
    required this.id,
    required this.username,
    this.email,
    required this.profileImage,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) =>
      _$ChatUserFromJson(json);
  Map<String, dynamic> toJson() => _$ChatUserToJson(this);
}
