import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_provider.dart';
import '../../../core/utils/logger_provider.dart';
import '../domain/models/chat_room_list_item.dart';
import '../domain/models/chat_room_detail.dart';
import '../domain/models/message.dart';

part 'chat_api.g.dart';

class PaginatedResponse<T> {
  final List<T> results;
  final String? next;
  final String? previous;
  final int count;

  const PaginatedResponse({
    required this.results,
    required this.next,
    required this.previous,
    required this.count,
  });
}

class ChatApi {
  final Dio _dio;
  final Logger _logger;

  ChatApi({required Dio dio, required Logger logger})
    : _dio = dio,
      _logger = logger;

  /// ✅ 채팅방 목록 조회 (목록용 모델)
  Future<PaginatedResponse<ChatRoomListItem>> getChatRooms({
    int page = 1,
  }) async {
    try {
      _logger.d('💬 채팅방 목록 요청: page=$page');

      final response = await _dio.get(
        'chat/rooms/',
        queryParameters: {'page': page},
      );

      _logger.i('✅ 채팅방 목록 조회 성공');
      _logger.d('🧾 chat rooms raw response: ${response.data}');

      // 페이지네이션(Map) 응답
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final rawList = (data['results'] as List<dynamic>? ?? []);

        final rooms = rawList
            .whereType<Map<String, dynamic>>()
            .map(ChatRoomListItem.fromJson)
            .toList();

        return PaginatedResponse(
          results: rooms,
          next: data['next'] as String?,
          previous: data['previous'] as String?,
          count: (data['count'] as num?)?.toInt() ?? rooms.length,
        );
      }

      // List 직접 응답
      if (response.data is List) {
        final rawList = response.data as List<dynamic>;

        final rooms = rawList
            .whereType<Map<String, dynamic>>()
            .map(ChatRoomListItem.fromJson)
            .toList();

        return PaginatedResponse(
          results: rooms,
          next: null,
          previous: null,
          count: rooms.length,
        );
      }

      throw StateError(
        'Unexpected response type: ${response.data.runtimeType}',
      );
    } on DioException catch (e) {
      _logger.e('❌ 채팅방 목록 조회 실패: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }

  /// ✅ 채팅방 생성/조회 (상세 모델)
  Future<ChatRoomDetail> createOrGetChatRoom(int bookId) async {
    try {
      _logger.d('💬 채팅방 생성/조회 요청: bookId=$bookId');

      final response = await _dio.post(
        'chat/rooms/create/',
        data: {'book_id': bookId},
      );

      _logger.i('✅ 채팅방 생성/조회 성공');
      _logger.d('🧾 create room raw response: ${response.data}');

      if (response.data is! Map<String, dynamic>) {
        throw StateError(
          'Unexpected response type: ${response.data.runtimeType}',
        );
      }

      return ChatRoomDetail.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _logger.e('❌ 채팅방 생성/조회 실패: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }

  /// ✅ 채팅방 상세 조회 (상세 모델)
  Future<ChatRoomDetail> getChatRoom(int roomId) async {
    try {
      _logger.d('💬 채팅방 상세 요청: roomId=$roomId');

      final response = await _dio.get('chat/rooms/$roomId/');

      _logger.i('✅ 채팅방 상세 조회 성공');
      _logger.d('🧾 chatroom detail raw response: ${response.data}');

      if (response.data is! Map<String, dynamic>) {
        throw StateError(
          'Unexpected response type: ${response.data.runtimeType}',
        );
      }

      return ChatRoomDetail.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _logger.e('❌ 채팅방 상세 조회 실패: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }

  /// 메시지 목록 조회 (너 기존 구조 유지)
  Future<Map<String, dynamic>> getMessages(int roomId, {int page = 1}) async {
    try {
      _logger.d('💬 메시지 목록 요청: roomId=$roomId, page=$page');

      final response = await _dio.get(
        'chat/rooms/$roomId/messages/',
        queryParameters: {'page': page},
      );

      _logger.i('✅ 메시지 목록 조회 성공');

      // 페이지네이션(Map) 응답
      if (response.data is Map && response.data['results'] != null) {
        return {
          'results': (response.data['results'] as List<dynamic>)
              .map((json) => Message.fromJson(json as Map<String, dynamic>))
              .toList(),
          'next': response.data['next'] as String?,
          'previous': response.data['previous'] as String?,
          'count': (response.data['count'] as num?)?.toInt() ?? 0,
        };
      }

      // List 직접 응답
      final messages = (response.data as List<dynamic>)
          .map((json) => Message.fromJson(json as Map<String, dynamic>))
          .toList();

      return {
        'results': messages,
        'next': null,
        'previous': null,
        'count': messages.length,
      };
    } on DioException catch (e) {
      _logger.e('❌ 메시지 목록 조회 실패: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }

  Future<int> getUnreadCount() async {
    try {
      _logger.d('💬 안 읽은 메시지 개수 요청');

      final response = await _dio.get('chat/unread-count/');

      _logger.i('✅ 안 읽은 메시지 개수 조회 성공');

      return response.data['unread_count'] ?? 0;
    } on DioException catch (e) {
      _logger.e('❌ 안 읽은 메시지 개수 조회 실패: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }
}

@riverpod
ChatApi chatApi(Ref ref) {
  final dio = ref.watch(dioProvider);
  final logger = ref.watch(loggerProvider);
  return ChatApi(dio: dio, logger: logger);
}
