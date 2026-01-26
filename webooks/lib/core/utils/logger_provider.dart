import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'logger_provider.g.dart';

/// Logger Provider
/// 앱 전역에서 일관된 로그 출력을 위해 사용
@Riverpod(keepAlive: true)
Logger logger(Ref ref) {
  return Logger(
    printer: PrettyPrinter(
      methodCount: 0, // 호출 스택 표시 안 함
      errorMethodCount: 5, // 에러 시에만 스택 5개 표시
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );
}
