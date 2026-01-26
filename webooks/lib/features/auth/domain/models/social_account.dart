import 'package:json_annotation/json_annotation.dart';

part 'social_account.g.dart';

enum SocialProvider {
  @JsonValue('kakao')
  kakao,
  @JsonValue('google')
  google,
}

@JsonSerializable()
class SocialAccount {
  final int id;
  final SocialProvider provider;
  @JsonKey(name: 'provider_user_oid')
  final String providerUserOid;

  SocialAccount({
    required this.id,
    required this.provider,
    required this.providerUserOid,
  });

  factory SocialAccount.fromJson(Map<String, dynamic> json) =>
      _$SocialAccountFromJson(json);

  Map<String, dynamic> toJson() => _$SocialAccountToJson(this);

  @override
  String toString() =>
      'SocialAccount(provider: $provider, providerUserOid: $providerUserOid)';
}
