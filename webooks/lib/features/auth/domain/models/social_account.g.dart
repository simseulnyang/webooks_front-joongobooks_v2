// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SocialAccount _$SocialAccountFromJson(Map<String, dynamic> json) =>
    SocialAccount(
      id: (json['id'] as num).toInt(),
      provider: $enumDecode(_$SocialProviderEnumMap, json['provider']),
      providerUserOid: json['provider_user_oid'] as String,
    );

Map<String, dynamic> _$SocialAccountToJson(SocialAccount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'provider': _$SocialProviderEnumMap[instance.provider]!,
      'provider_user_oid': instance.providerUserOid,
    };

const _$SocialProviderEnumMap = {
  SocialProvider.kakao: 'kakao',
  SocialProvider.google: 'google',
};
