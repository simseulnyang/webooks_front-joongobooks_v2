import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'core/config/env_config.dart';

// 디버깅으로 임시 사용하는 라이브러리
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "assets/.env");

  KakaoSdk.init(nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY']!);

  EnvConfig.validateConfig();

  await _printKeyHash();

  runApp(const ProviderScope(child: MyApp()));
}

Future<void> _printKeyHash() async {
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    final packageName = packageInfo.packageName;

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📦 Package Name: $packageName');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // Android에서만 실행
    if (defaultTargetPlatform == TargetPlatform.android) {
      final signature = await KakaoSdk.origin;
      print('🔑 Kakao Key Hash: $signature');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
  } catch (e) {
    print('❌ Key Hash 출력 실패: $e');
  }
}
