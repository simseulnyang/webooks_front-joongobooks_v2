import '../domain/models/chat_room_detail.dart';
import '../domain/models/chat_room_list_item.dart' as list;
import '../domain/models/message.dart';

class ChatRoomListState {
  final List<list.ChatRoomListItem> rooms;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final int currentPage;

  const ChatRoomListState({
    this.rooms = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.currentPage = 1,
  });

  ChatRoomListState copyWith({
    List<list.ChatRoomListItem>? rooms,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    int? currentPage,
  }) {
    return ChatRoomListState(
      rooms: rooms ?? this.rooms,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class ChatRoomState {
  final ChatRoomDetail? room;
  final List<Message> messages;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final bool isConnected;
  final String? error;
  final int currentPage;

  const ChatRoomState({
    this.room,
    this.messages = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.isConnected = false,
    this.error,
    this.currentPage = 1,
  });

  ChatRoomState copyWith({
    ChatRoomDetail? room,
    List<Message>? messages,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    bool? isConnected,
    String? error,
    int? currentPage,
  }) {
    return ChatRoomState(
      room: room ?? this.room,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      isConnected: isConnected ?? this.isConnected,
      error: error,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}
