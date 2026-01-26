import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class AuthResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;

  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  final User user;

  @JsonKey(name: 'is_created')
  final bool isCreated;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.isCreated,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);

  @override
  String toString() =>
      'AuthResponse(user: ${user.email}, isCreated: $isCreated)';
}
