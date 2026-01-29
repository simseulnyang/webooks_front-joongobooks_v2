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

  @override
  ChatRoomState build(int roomId) {
    // ✅ dispose 시 정리
    ref.onDispose(() {
      _disconnectWebSocket();
    });

    // ✅ build는 sync여야 하니까, 실제 작업은 microtask로
    Future.microtask(() async {
      await _loadRoom();
      await _loadMessages();
      await _connectWebSocket();
    });

    return const ChatRoomState();
  }

  Future<void> _loadRoom() async {
    try {
      final chatApi = ref.read(chatApiProvider);
      final ChatRoomDetail room = await chatApi.getChatRoom(roomId);

      state = state.copyWith(room: room);
    } on DioException catch (e) {
      final logger = ref.read(loggerProvider);
      logger.e('❌ 채팅방 정보 로드 실패', error: e);

      final apiError = ApiError.fromDioException(e);
      state = state.copyWith(error: apiError.message);
    }
  }

  Future<void> _loadMessages() async {
    final logger = ref.read(loggerProvider);
    logger.d('📌 _loadMessages called');

    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final chatApi = ref.read(chatApiProvider);
      final response = await chatApi.getMessages(roomId, page: 1);

      final results = (response['results'] as List<dynamic>? ?? []);
      final messages = results.cast<Message>();

      final hasNext = response['next'] != null;

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
      state = state.copyWith(isLoading: false, error: apiError.message);
    } catch (e, stackTrace) {
      final logger = ref.read(loggerProvider);
      logger.e('❌ 예상치 못한 오류', error: e, stackTrace: stackTrace);

      state = state.copyWith(
        isLoading: false,
        error: '메시지를 불러오는 중 오류가 발생했습니다.',
      );
    }
  }

  Future<void> loadMoreMessages() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final chatApi = ref.read(chatApiProvider);
      final nextPage = state.currentPage + 1;
      final response = await chatApi.getMessages(roomId, page: nextPage);

      final results = (response['results'] as List<dynamic>? ?? []);

      final newMessages = results.cast<Message>();

      final hasNext = response['next'] != null;

      state = state.copyWith(
        messages: [...state.messages, ...newMessages],
        isLoadingMore: false,
        hasMore: hasNext,
        currentPage: nextPage,
      );
    } on DioException catch (e) {
      final logger = ref.read(loggerProvider);
      logger.e('❌ 추가 메시지 로드 실패', error: e);

      state = state.copyWith(isLoadingMore: false);
    } catch (e, stackTrace) {
      final logger = ref.read(loggerProvider);
      logger.e('❌ 추가 메시지 로드 중 예상치 못한 오류', error: e, stackTrace: stackTrace);

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

      state = state.copyWith(isConnected: true);
    } catch (e) {
      final logger = ref.read(loggerProvider);
      logger.e('❌ WebSocket 연결 실패', error: e);

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

    // ✅ 상태도 끊김으로 반영
    state = state.copyWith(isConnected: false);
  }

  void _onMessageReceived(Message message) {
    final logger = ref.read(loggerProvider);
    logger.d('📥 메시지 수신: ${message.content} / before=${state.messages.length}');

    final auth = ref.read(authProvider);
    final myId = auth.user?.id;

    // ✅ (A) 내가 보낸 메시지 echo면 무시 (tempMessage 이미 추가했으니까)
    if (myId != null && message.sender == myId) {
      logger.d('🧹 내 메시지 echo 무시 (sender=$myId, id=${message.id})');
      return;
    }

    // ✅ (B) 서버 메시지 id 기준 중복 방지
    if (message.id > 0 && state.messages.any((m) => m.id == message.id)) {
      logger.d('🧹 중복 메시지 무시 (id=${message.id})');
      return;
    }

    state = state.copyWith(messages: [...state.messages, message]);

    logger.d('📥 after=${state.messages.length}');
  }

  void _onConnectionChanged(bool isConnected) {
    final logger = ref.read(loggerProvider);
    logger.d('🔌 WebSocket 연결 상태: $isConnected');

    state = state.copyWith(isConnected: isConnected);
  }

  void _onError(String error) {
    final logger = ref.read(loggerProvider);
    logger.e('❌ WebSocket 에러: $error');

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
    final room = state.room;

    if (me != null && room != null) {
      final tempMessage = Message(
        id: -DateTime.now().millisecondsSinceEpoch,
        room: room.id,
        sender: me.id,
        senderUsername: me.username,
        senderEmail: me.email,
        content: content,
        createdAt: DateTime.now().toIso8601String(),
        isRead: false,
      );
      state = state.copyWith(messages: [...state.messages, tempMessage]);
    }

    _webSocketService!.sendMessage(content);
  }

  void markMessagesAsRead(List<int> messageIds) {
    if (_webSocketService == null || !state.isConnected) return;
    _webSocketService!.markAsRead(messageIds);
  }

  Future<void> refresh() async {
    // ✅ 여기 핵심: 상태 초기화만 하면 isConnected가 false로 고정될 수 있음
    // 1) 소켓 끊고
    _disconnectWebSocket();

    // 2) 상태 초기화 후 다시 로드 + 재연결
    state = const ChatRoomState();
    await _loadRoom();
    await _loadMessages();
    await _connectWebSocket();
  }
}
