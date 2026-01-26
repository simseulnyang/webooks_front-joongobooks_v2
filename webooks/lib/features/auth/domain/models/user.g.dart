// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
  email: json['email'] as String,
  username: json['username'] as String,
  profileImage: json['profile_image'] as String,
  createdAt: json['created_at'] as String,
  socialAccounts: (json['social_accounts'] as List<dynamic>?)
      ?.map((e) => SocialAccount.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'username': instance.username,
  'profile_image': instance.profileImage,
  'created_at': instance.createdAt,
  'social_accounts': instance.socialAccounts,
};
