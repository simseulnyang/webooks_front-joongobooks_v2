// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatRoomList)
final chatRoomListProvider = ChatRoomListProvider._();

final class ChatRoomListProvider
    extends $NotifierProvider<ChatRoomList, ChatRoomListState> {
  ChatRoomListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatRoomListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatRoomListHash();

  @$internal
  @override
  ChatRoomList create() => ChatRoomList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatRoomListState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatRoomListState>(value),
    );
  }
}

String _$chatRoomListHash() => r'0c2fd59e8cfca8084d53f6043338ebf9489733a2';

abstract class _$ChatRoomList extends $Notifier<ChatRoomListState> {
  ChatRoomListState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ChatRoomListState, ChatRoomListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChatRoomListState, ChatRoomListState>,
              ChatRoomListState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
