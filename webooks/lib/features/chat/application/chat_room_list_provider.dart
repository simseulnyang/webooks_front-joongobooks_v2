import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/application/auth_provider.dart';
import '../../../core/error/api_error.dart';
import '../../../core/utils/logger_provider.dart';
import '../data/chat_api.dart';
import '../domain/models/chat_room_list_item.dart';
import 'chat_state.dart';

part 'chat_room_list_provider.g.dart';

@riverpod
class ChatRoomList extends _$ChatRoomList {
  bool _didAutoLoad = false;

  @override
  ChatRoomListState build() {
    final auth = ref.watch(authProvider);

    if (!auth.isLoggedIn) {
      _didAutoLoad = false;
      return const ChatRoomListState();
    }

    if (!_didAutoLoad) {
      _didAutoLoad = true;
      Future.microtask(_loadRooms);
    }

    return const ChatRoomListState();
  }

  /// ✅ 채팅방 정렬 기준 시간 계산
  DateTime _roomSortTime(ChatRoomListItem room) {
    final lm = room.lastMessage?.createdAt;
    if (lm != null && lm.isNotEmpty) {
      final dt = DateTime.tryParse(lm);
      if (dt != null) return dt.toUtc();
    }

    final upDt = DateTime.tryParse(room.updatedAt);
    if (upDt != null) return upDt.toUtc();

    final crDt = DateTime.tryParse(room.createdAt);
    if (crDt != null) return crDt.toUtc();

    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }

  List<ChatRoomListItem> _sortRooms(List<ChatRoomListItem> rooms) {
    final list = [...rooms];
    list.sort((a, b) => _roomSortTime(b).compareTo(_roomSortTime(a)));
    return list;
  }

  List<ChatRoomListItem> _mergeAndSort(
    List<ChatRoomListItem> oldRooms,
    List<ChatRoomListItem> newRooms,
  ) {
    final map = <int, ChatRoomListItem>{};

    for (final r in oldRooms) {
      map[r.id] = r;
    }
    for (final r in newRooms) {
      map[r.id] = r;
    }

    return _sortRooms(map.values.toList());
  }

  /// 📥 최초 채팅방 목록 로드
  Future<void> _loadRooms() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final chatApi = ref.read(chatApiProvider);
      final response = await chatApi.getChatRooms(page: 1);

      final rooms = response.results;
      final hasNext = response.next != null;

      state = state.copyWith(
        rooms: _sortRooms(rooms),
        isLoading: false,
        hasMore: hasNext,
        currentPage: 1,
      );
    } on DioException catch (e) {
      final logger = ref.read(loggerProvider);
      logger.e('❌ 채팅방 목록 로드 실패', error: e);

      final apiError = ApiError.fromDioException(e);
      state = state.copyWith(isLoading: false, error: apiError.message);
    } catch (e, stackTrace) {
      final logger = ref.read(loggerProvider);
      logger.e('❌ 예상치 못한 오류', error: e, stackTrace: stackTrace);

      state = state.copyWith(
        isLoading: false,
        error: '채팅방 목록을 불러오는 중 오류가 발생했습니다.',
      );
    }
  }

  /// 📥 추가 페이지 로드
  Future<void> loadMoreRooms() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final chatApi = ref.read(chatApiProvider);
      final nextPage = state.currentPage + 1;
      final response = await chatApi.getChatRooms(page: nextPage);

      final newRooms = response.results;
      final hasNext = response.next != null && newRooms.isNotEmpty;

      state = state.copyWith(
        rooms: _mergeAndSort(state.rooms, newRooms),
        isLoadingMore: false,
        hasMore: hasNext,
        currentPage: nextPage,
        error: null,
      );
    } on DioException catch (e) {
      final logger = ref.read(loggerProvider);
      logger.e('❌ 추가 채팅방 로드 실패', error: e);
      state = state.copyWith(isLoadingMore: false);
    } catch (e, stackTrace) {
      final logger = ref.read(loggerProvider);
      logger.e('❌ 추가 채팅방 로드 중 오류', error: e, stackTrace: stackTrace);
      state = state.copyWith(isLoadingMore: false);
    }
  }

  /// 🔄 새로고침
  Future<void> refresh() async {
    state = const ChatRoomListState();
    await _loadRooms();
  }
}
