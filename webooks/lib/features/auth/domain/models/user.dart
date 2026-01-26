import 'package:json_annotation/json_annotation.dart';
import 'social_account.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String email;
  final String username;
  @JsonKey(name: 'profile_image')
  final String profileImage;
  @JsonKey(name: 'created_at')
  final String createdAt;

  /// 연결된 소셜 계정 목록
  @JsonKey(name: 'social_accounts')
  final List<SocialAccount>? socialAccounts;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.profileImage,
    required this.createdAt,
    this.socialAccounts,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  bool hasProvider(SocialProvider provider) {
    if (socialAccounts == null) return false;
    return socialAccounts!.any((account) => account.provider == provider);
  }

  List<SocialProvider> get connectedProviders {
    if (socialAccounts == null) return [];
    return socialAccounts!.map((account) => account.provider).toList();
  }

  @override
  String toString() => 'User(id: $id, email: $email, username: $username)';
}
