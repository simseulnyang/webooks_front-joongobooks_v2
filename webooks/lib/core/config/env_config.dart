import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  EnvConfig._();

  static String get apiBaseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('API_BASE_URL이 .env 파일에 설정되지 않았습니다.');
    }
    return url;
  }

  static String get wsBaseUrl {
    final url = dotenv.env['WS_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('WS_BASE_URL이 .env 파일에 설정되지 않았습니다.');
    }
    return url;
  }

  static String get kakaoNativeAppKey {
    return dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '';
  }

  static String get kakaoRedirectUri {
    return dotenv.env['KAKAO_REDIRECT_URI'] ?? '';
  }

  static String get kakaoRestApiKey {
    return dotenv.env['KAKAO_REST_API_KEY'] ?? '';
  }

  static String get googleWebClientId {
    return dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';
  }

  static bool get isKakaoConfigured =>
      kakaoNativeAppKey.isNotEmpty && kakaoRestApiKey.isNotEmpty;

  static bool get isGoogleConfigured => googleWebClientId.isNotEmpty;

  static void validateConfig() {
    final errors = <String>[];

    if (apiBaseUrl.isEmpty) {
      errors.add('API_BASE_URL이 설정되지 않았습니다.');
    }

    if (!isKakaoConfigured) {
      errors.add('Kakao API 키가 설정되지 않았습니다.');
    }

    if (!isGoogleConfigured) {
      errors.add('Google Web Client ID가 설정되지 않았습니다.');
    }

    if (errors.isNotEmpty) {
      throw Exception('환경 변수 설정 오류:\n${errors.join('\n')}');
    }
  }
}
