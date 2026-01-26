import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'secure_storage.g.dart';

class SecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorage(this._storage);

  // 데이터 저장
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // 데이터 읽기
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  // 데이터 삭제
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  // 모든 데이터 삭제 (로그아웃 시 사용)
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}

// SecureStorage Provider
@riverpod
SecureStorage secureStorage(Ref ref) {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  return SecureStorage(storage);
}
