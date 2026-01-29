// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatRoom)
final chatRoomProvider = ChatRoomFamily._();

final class ChatRoomProvider
    extends $NotifierProvider<ChatRoom, ChatRoomState> {
  ChatRoomProvider._({
    required ChatRoomFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'chatRoomProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatRoomHash();

  @override
  String toString() {
    return r'chatRoomProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChatRoom create() => ChatRoom();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatRoomState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatRoomState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChatRoomProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatRoomHash() => r'b4bbfa2f331419df2864e35eb2281f1a0328f84e';

final class ChatRoomFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatRoom,
          ChatRoomState,
          ChatRoomState,
          ChatRoomState,
          int
        > {
  ChatRoomFamily._()
    : super(
        retry: null,
        name: r'chatRoomProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChatRoomProvider call(int roomId) =>
      ChatRoomProvider._(argument: roomId, from: this);

  @override
  String toString() => r'chatRoomProvider';
}

abstract class _$ChatRoom extends $Notifier<ChatRoomState> {
  late final _$args = ref.$arg as int;
  int get roomId => _$args;

  ChatRoomState build(int roomId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ChatRoomState, ChatRoomState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChatRoomState, ChatRoomState>,
              ChatRoomState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
