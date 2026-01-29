import 'dart:async';
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../core/config/env_config.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/models/message.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final TokenStorage _tokenStorage;
  final Logger _logger;
  final int roomId;
  final int? _currentUserId;

  final StreamController<Message> _messageController =
      StreamController<Message>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  Stream<Message> get messages => _messageController.stream;
  Stream<String> get errors => _errorController.stream;
  Stream<bool> get connectionStatus => _connectionController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  WebSocketService({
    required this.roomId,
    required TokenStorage tokenStorage,
    required Logger logger,
    int? currentUserId,
  }) : _tokenStorage = tokenStorage,
       _logger = logger,
       _currentUserId = currentUserId;

  /// WebSocket 연결
  Future<void> connect() async {
    if (_isConnected) {
      _logger.w('⚠️ 이미 WebSocket에 연결되어 있습니다.');
      return;
    }

    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      // WebSocket URL 생성
      final wsUrl = '${EnvConfig.wsBaseUrl}chat/$roomId/';
      _logger.d('🔌 WebSocket 연결 시도: $wsUrl');

      // WebSocket 연결
      _channel = WebSocketChannel.connect(
        Uri.parse(wsUrl),
        protocols: ['Authorization', 'Bearer $token'],
      );

      // 메시지 리스닝
      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      _isConnected = true;
      _connectionController.add(true);
      _logger.i('✅ WebSocket 연결 성공');
    } catch (e) {
      _logger.e('❌ WebSocket 연결 실패: $e');
      _errorController.add('연결 실패: $e');
      _isConnected = false;
      _connectionController.add(false);
      rethrow;
    }
  }

  /// 메시지 전송
  void sendMessage(String content) {
    if (!_isConnected || _channel == null) {
      _logger.w('⚠️ WebSocket이 연결되어 있지 않습니다.');
      return;
    }

    final message = {'type': 'message', 'content': content};

    _channel!.sink.add(jsonEncode(message));
    _logger.d('📤 메시지 전송(ws): $content');
  }

  /// 메시지 읽음 처리
  void markAsRead(List<int> messageIds) {
    if (!_isConnected || _channel == null) {
      return;
    }

    final data = {'type': 'read', 'message_ids': messageIds};

    _channel!.sink.add(jsonEncode(data));
    _logger.d('✅ 메시지 읽음 처리: $messageIds');
  }

  /// WebSocket 메시지 수신 처리
  void _onMessage(dynamic data) {
    try {
      _logger.d('📥 raw: $data');

      final Map<String, dynamic> json = jsonDecode(data as String);
      _logger.d('📥 decoded: $json');

      final type = json['type'] as String?;
      _logger.d('📥 type=$type');

      switch (type) {
        case 'chat_message':
          final messageData = json['message'] as Map<String, dynamic>;
          _logger.d('📥 messageData: $messageData');

          // ✅ 1) senderId 추출 (sender가 Map일 수도 있고 int일 수도 있음)
          final senderValue = messageData['sender'];
          int? senderId;
          if (senderValue is Map) {
            final v = senderValue['id'];
            if (v is num) senderId = v.toInt();
            if (v is String) senderId = int.tryParse(v);
          } else if (senderValue is num) {
            senderId = senderValue.toInt();
          } else if (senderValue is String) {
            senderId = int.tryParse(senderValue);
          }

          // ✅ 2) 내가 보낸 메시지 에코는 무시 (optimistic UI 쓰는 경우 중복 방지)
          if (_currentUserId != null && senderId == _currentUserId) {
            _logger.d('🧹 WS echo ignored (my message). senderId=$senderId');
            return;
          }

          final message = Message.fromWebSocket(messageData);

          // ✅ 3) 서버 id 중복 방지: 같은 id 메시지가 이미 UI에 있으면 또 추가하지 않도록
          // 여기서는 _messageController에 흘리기 전에, "중복 방지" 정보를 서비스가 갖고 있어야 함.
          // (서비스가 메시지 목록을 모르기 때문에, 최소한 여기서는 pass 하고 provider에서 중복 방지 권장)
          _messageController.add(message);
          break;

        case 'error':
          final errorMsg = (json['message'] ?? json['error'] ?? 'unknown')
              .toString();
          _logger.e('❌ 서버 에러: $errorMsg');
          _errorController.add(errorMsg);
          break;

        default:
          _logger.w('⚠️ 알 수 없는 메시지 타입: $type / json=$json');
      }
    } catch (e) {
      _logger.e('❌ 메시지 파싱 실패: $e');
      _errorController.add('메시지 파싱 실패: $e');
    }
  }

  /// WebSocket 에러 처리
  void _onError(dynamic error) {
    _logger.e('❌ WebSocket 에러: $error');
    _errorController.add('연결 오류: $error');
    _isConnected = false;
    _connectionController.add(false);
  }

  /// WebSocket 연결 종료 처리
  void _onDone() {
    _logger.i('🔌 WebSocket 연결 종료');
    _isConnected = false;
    _connectionController.add(false);
  }

  /// WebSocket 연결 해제
  void disconnect() {
    _logger.d('🔌 WebSocket 연결 해제 시도');
    _channel?.sink.close();
    _isConnected = false;
    _connectionController.add(false);
  }

  /// 리소스 정리
  void dispose() {
    disconnect();
    _messageController.close();
    _errorController.close();
    _connectionController.close();
  }
}
