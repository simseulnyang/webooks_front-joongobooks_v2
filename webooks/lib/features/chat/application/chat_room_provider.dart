import 'dart:async';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/application/auth_provider.dart';
import '../../../core/error/api_error.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/utils/logger_provider.dart';
import '../data/chat_api.dart';
import '../data/websocket_service.dart';
import '../domain/models/message.dart';
import '../domain/models/chat_room_detail.dart';
import 'chat_state.dart';

part 'chat_room_provider.g.dart';

@riverpod
class ChatRoom extends _$ChatRoom {
  WebSocketService? _webSocketService;
  StreamSubscription<Message>? _messageSubscription;
  StreamSubscription<bool>? _connectionSubscription;
  StreamSubscription<String>? _errorSubscription;

  bool _alive = true;

  @override
  ChatRoomState build(int roomId) {
    _alive = true;

    ref.onDispose(() {
      _alive = false;
      _disconnectWebSocket();
    });

    // build는 sync여야 하므로 microtask로 비동기 초기화
    Future.microtask(() async {
      if (!_alive) return;
      await _loadRoom();
      if (!_alive) return;
      await _loadMessages();
      if (!_alive) return;
      await _connectWebSocket();
    });

    return const ChatRoomState();
  }

  Future<void> _loadRoom() async {
    try {
      final chatApi = ref.read(chatApiProvider);
      final ChatRoomDetail room = await chatApi.getChatRoom(roomId);

      state = state.copyWith(room: room, error: null);
    } on DioException catch (e) {
      final logger = ref.read(loggerProvider);
      logger.e('❌ 채팅방 정보 로드 실패(Dio)', error: e);

      final apiError = ApiError.fromDioException(e);
      state = state.copyWith(error: apiError.message);
    } catch (e, stackTrace) {
      final logger = ref.read(loggerProvider);
      logger.e('❌ 채팅방 정보 파싱/처리 실패', error: e, stackTrace: stackTrace);

      if (!_alive) return;
      state = state.copyWith(error: '채팅방 정보를 불러오는 중 오류가 발생했습니다.');
    }
  }

  Future<void> _loadMessages() async {
    if (state.isLoading) return;

    if (!_alive) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final chatApi = ref.read(chatApiProvider);
      final response = await chatApi.getMessages(roomId, page: 1);

      final results = (response['results'] as List<dynamic>? ?? const []);

      // ✅ 핵심: cast<Message>() 금지 (안전하게 변환)
      final List<Message> messages = results.whereType<Message>().toList();

      final hasNext = response['next'] != null;

      if (!_alive) return;
      state = state.copyWith(
        messages: messages,
        isLoading: false,
        hasMore: hasNext,
        currentPage: 1,
      );
    } on DioException catch (e) {
      final logger = ref.read(loggerProvider);
      logger.e('❌ 메시지 로드 실패', error: e);

      final apiError = ApiError.fromDioException(e);
      if (!_alive) return;
      state = state.copyWith(isLoading: false, error: apiError.message);
    } catch (e, stackTrace) {
      final logger = ref.read(loggerProvider);
      logger.e('❌ 예상치 못한 오류', error: e, stackTrace: stackTrace);

      if (!_alive) return;
      state = state.copyWith(
        isLoading: false,
        error: '메시지를 불러오는 중 오류가 발생했습니다.',
      );
    }
  }

  Future<void> loadMoreMessages() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    if (!_alive) return;
    state = state.copyWith(isLoadingMore: true);

    try {
      final chatApi = ref.read(chatApiProvider);
      final nextPage = state.currentPage + 1;
      final response = await chatApi.getMessages(roomId, page: nextPage);

      final results = (response['results'] as List<dynamic>? ?? const []);

      // ✅ 안전 변환
      final List<Message> newMessages = results.whereType<Message>().toList();

      final hasNext = response['next'] != null;

      if (!_alive) return;
      state = state.copyWith(
        messages: [...state.messages, ...newMessages],
        isLoadingMore: false,
        hasMore: hasNext,
        currentPage: nextPage,
      );
    } on DioException catch (e) {
      final logger = ref.read(loggerProvider);
      logger.e('❌ 추가 메시지 로드 실패', error: e);

      if (!_alive) return;
      state = state.copyWith(isLoadingMore: false);
    } catch (e, stackTrace) {
      final logger = ref.read(loggerProvider);
      logger.e('❌ 추가 메시지 로드 중 예상치 못한 오류', error: e, stackTrace: stackTrace);

      if (!_alive) return;
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> _connectWebSocket() async {
    if (_webSocketService != null) return;

    try {
      final tokenStorage = ref.read(tokenStorageProvider);
      final logger = ref.read(loggerProvider);

      final service = WebSocketService(
        roomId: roomId,
        tokenStorage: tokenStorage,
        logger: logger,
      );

      _messageSubscription = service.messages.listen(_onMessageReceived);
      _connectionSubscription = service.connectionStatus.listen(
        _onConnectionChanged,
      );
      _errorSubscription = service.errors.listen(_onError);

      _webSocketService = service;

      await service.connect();

      if (!_alive) return;
      state = state.copyWith(isConnected: true);
    } catch (e) {
      final logger = ref.read(loggerProvider);
      logger.e('❌ WebSocket 연결 실패', error: e);

      if (!_alive) return;
      state = state.copyWith(isConnected: false, error: 'WebSocket 연결 실패: $e');

      _disconnectWebSocket();
    }
  }

  void _disconnectWebSocket() {
    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();
    _errorSubscription?.cancel();

    _messageSubscription = null;
    _connectionSubscription = null;
    _errorSubscription = null;

    _webSocketService?.dispose();
    _webSocketService = null;

    if (!_alive) return;
    state = state.copyWith(isConnected: false);
  }

  void _onMessageReceived(Message message) {
    final logger = ref.read(loggerProvider);
    logger.d('📥 메시지 수신: ${message.content} / before=${state.messages.length}');

    final myId = ref.read(authProvider).user?.id;

    // ✅ 서버 메시지 id 기준 중복 방지 (먼저)
    if (message.id > 0 && state.messages.any((m) => m.id == message.id)) {
      logger.d('🧹 중복 메시지 무시 (id=${message.id})');
      return;
    }

    // ✅ "내가 보낸 에코"면: 무시하지 말고 tempMessage를 교체!
    if (myId != null && message.sender == myId) {
      final idx = state.messages.lastIndexWhere(
        (m) =>
            m.id < 0 && // temp
            m.sender == myId &&
            m.content == message.content,
      );

      if (idx != -1) {
        final updated = [...state.messages];
        updated[idx] = message; // ✅ temp → 서버 메시지로 교체
        state = state.copyWith(messages: updated);
        logger.d(
          '✅ tempMessage 교체 완료 (tempIndex=$idx, serverId=${message.id})',
        );
        return;
      }

      // temp를 못 찾으면(예: temp가 안 들어간 상태) 그냥 추가
      state = state.copyWith(messages: [...state.messages, message]);
      logger.d('✅ temp 없음 → 내 에코 메시지 추가 (id=${message.id})');
      return;
    }

    if (!_alive) return;
    state = state.copyWith(messages: [...state.messages, message]);
  }

  void _onConnectionChanged(bool isConnected) {
    if (!_alive) return;
    state = state.copyWith(isConnected: isConnected);
  }

  void _onError(String error) {
    final logger = ref.read(loggerProvider);
    logger.e('❌ WebSocket 에러: $error');

    if (!_alive) return;
    state = state.copyWith(error: error, isConnected: false);
  }

  void sendMessage(String content) {
    if (_webSocketService == null || !state.isConnected) {
      final logger = ref.read(loggerProvider);
      logger.w('⚠️ WebSocket이 연결되어 있지 않습니다. (sendMessage 무시)');
      return;
    }

    final auth = ref.read(authProvider);
    final me = auth.user;

    // ✅ optimistic UI (임시 메시지)
    if (me != null) {
      final tempMessage = Message(
        id: -DateTime.now().millisecondsSinceEpoch,
        room: roomId,
        sender: me.id,
        senderUsername: me.username,
        senderEmail: me.email,
        content: content,
        createdAt: DateTime.now().toIso8601String(),
        isRead: false,
      );

      if (!_alive) return;
      state = state.copyWith(messages: [...state.messages, tempMessage]);
    }

    _webSocketService!.sendMessage(content);
  }

  /// ✅ 읽음 처리: 서버로 전송 + 로컬 state도 즉시 반영(뱃지/표시 즉시 갱신)
  void markMessagesAsRead(List<int> messageIds) {
    if (_webSocketService == null || !state.isConnected) return;
    if (messageIds.isEmpty) return;

    _webSocketService!.markAsRead(messageIds);

    // ✅ 로컬에서도 isRead=true 처리 (UX 즉시 반영)
    final updated = state.messages.map((m) {
      if (messageIds.contains(m.id)) {
        return m.copyWith(isRead: true);
      }
      return m;
    }).toList();

    if (!_alive) return;
    state = state.copyWith(messages: updated);
  }

  Future<void> refresh() async {
    _disconnectWebSocket();

    if (!_alive) return;
    state = const ChatRoomState();

    await _loadRoom();
    if (!_alive) return;
    await _loadMessages();
    if (!_alive) return;
    await _connectWebSocket();
  }
}
